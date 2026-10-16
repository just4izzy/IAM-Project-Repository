[CmdletBinding()]
param(
    [switch]$Execute
)


# Northstar Financial Services
# Joiner Lifecycle Automation - Version 1
# DRY RUN DEFAULT - Live provisioning requires -Execute

$ErrorActionPreference = "Stop"

# Locate project files
$ProjectRoot = Split-Path $PSScriptRoot -Parent

$RBACPath = Join-Path $ProjectRoot "config\rbac-entitlement-matrix.csv"
$RequestPath = Join-Path $ProjectRoot "requests\joiner-requests.csv"

# Verify required files exist
foreach ($Path in @($RBACPath, $RequestPath)) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file not found: $Path"
    }
}

# Import configuration
$RBAC = @(Import-Csv -LiteralPath $RBACPath)
$Requests = @(Import-Csv -LiteralPath $RequestPath)

if ($RBAC.Count -eq 0 -or $Requests.Count -eq 0) {
    throw "RBAC matrix or onboarding requests file is empty."
}

# Process each onboarding request
foreach ($Request in $Requests) {

    $EmployeeName = "$($Request.FirstName) $($Request.LastName)"


	Write-Host "`n=================================="
	Write-Host "Northstar Joiner - DRY RUN"
	Write-Host "=================================="


    # Verify approval
    if ($Request.ApprovalStatus -ne "Approved") {
        Write-Warning "$EmployeeName - Request not approved. Skipping."
        continue
    }

    # Match approved role to RBAC rules
    $MatchingRules = @(
        $RBAC | Where-Object {
            $_.Department -eq $Request.Department -and
            $_.JobRole -eq $Request.JobRole -and
            $_.Status -eq "Implemented"
        }
    )

    if ($MatchingRules.Count -eq 0) {
        Write-Warning "$EmployeeName - No matching RBAC rule. Skipping."
        continue
    }

    $RequiredGroups = @(
        $MatchingRules | Select-Object -ExpandProperty SecurityGroup -Unique
    )



# Validate the proposed employee and required groups
# READ-ONLY - No accounts or memberships are modified

# Check for an existing employee with the same display name
$ExistingUsers = @(
    Get-MgUser `
        -Filter "displayName eq '$EmployeeName'" `
        -Property Id,DisplayName,UserPrincipalName `
        -All `
        -ErrorAction Stop
)

if ($ExistingUsers.Count -gt 0) {
    Write-Warning "$EmployeeName - Possible duplicate account detected."
    Write-Warning "Onboarding stopped for manual review."
    continue
}

# Verify every required security group exists
$GroupsValid = $true

foreach ($GroupName in $RequiredGroups) {

    $MatchingGroups = @(
        Get-MgGroup `
            -Filter "displayName eq '$GroupName'" `
            -All `
            -ErrorAction Stop
    )

    if ($MatchingGroups.Count -ne 1) {
        Write-Warning "Expected exactly one group named $GroupName; found $($MatchingGroups.Count)."
        $GroupsValid = $false
    }
}

if (-not $GroupsValid) {
    Write-Warning "$EmployeeName - Group validation failed."
    continue
}


# Build and validate the proposed User Principal Name
$TenantDomain = "IzzysITLab.onmicrosoft.com"
$NewUserUPN = "$($Request.UserName)@$TenantDomain"

# Check for an existing account with this exact UPN
$ExistingUPN = @(
    Get-MgUser `
        -Filter "userPrincipalName eq '$NewUserUPN'" `
        -Property Id,DisplayName,UserPrincipalName `
        -ErrorAction Stop
)

if ($ExistingUPN.Count -gt 0) {
    Write-Warning "$NewUserUPN already exists."
    Write-Warning "Onboarding stopped to prevent a duplicate account."
    continue
}

Write-Host "UPN validation: PASSED"
Write-Host "Proposed UPN: $NewUserUPN"

Write-Host "Duplicate account check: PASSED"
Write-Host "Security group validation: PASSED"

    # Display proposed provisioning actions
    Write-Host "Employee: $EmployeeName"
    Write-Host "Username: $($Request.UserName)"
    Write-Host "Department: $($Request.Department)"
    Write-Host "Role: $($Request.JobRole)"
    Write-Host "Approval: $($Request.ApprovalStatus)"
    Write-Host "Required Groups: $($RequiredGroups -join ', ')"
    


if ($Execute) {
    Write-Host "Action: LIVE PROVISIONING"

    # The -Execute switch explicitly enables account creation.
    # Without -Execute, the script remains read-only.

    
# Obtain a temporary password securely at runtime.
# Do not hardcode passwords in scripts or CSV files.

$SecurePassword = Read-Host `
    "Enter a unique temporary password from your password manager" `
    -AsSecureString

$PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)

try {
    $TemporaryPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($PasswordPointer)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
}

if ([string]::IsNullOrWhiteSpace($TemporaryPassword)) {
    throw "Temporary password cannot be empty."
}

$PasswordProfile = @{
    Password = $TemporaryPassword
    ForceChangePasswordNextSignIn = $true
}


    $UserParameters = @{
        DisplayName = $EmployeeName
        UserPrincipalName = $NewUserUPN
        MailNickname = $Request.UserName
        GivenName = $Request.FirstName
        Surname = $Request.LastName
        Department = $Request.Department
        JobTitle = $Request.JobRole
        AccountEnabled = $false
        PasswordProfile = $PasswordProfile
    }
    
	# Track provisioning progress
	$AccountCreated = $false
	$GroupsAssigned = $false
	$ProvisioningComplete = $false

    

# Create the disabled Microsoft Entra ID account
try {
    try {
        $NewUser = New-MgUser @UserParameters -ErrorAction Stop
    }
    finally {
        # Clear references to temporary credentials
        $TemporaryPassword = $null
        $SecurePassword = $null
        $PasswordProfile = $null
        $UserParameters.PasswordProfile = $null
    }

    if (-not $NewUser.Id) {
        throw "Account creation returned no User ID."
    }

    $AccountCreated = $true

    Write-Host "Employee account created successfully."
    Write-Host "Account enabled: False"
    Write-Host "User ID: $($NewUser.Id)"
}
catch {
    Write-Warning "ACCOUNT CREATION FAILED: $EmployeeName"
    Write-Warning "Error: $($_.Exception.Message)"
    Write-Warning "Provisioning status requires investigation."
    throw
}

# Assign approved security groups
try {
    foreach ($GroupName in $RequiredGroups) {

        $TargetGroups = @(
            Get-MgGroup `
                -Filter "displayName eq '$GroupName'" `
                -All `
                -ErrorAction Stop
        )

        if ($TargetGroups.Count -ne 1) {
            throw "Expected exactly one group named '$GroupName'."
        }

        $GroupId = $TargetGroups[0].Id

        New-MgGroupMemberByRef `
            -GroupId $GroupId `
            -BodyParameter @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($NewUser.Id)"
            } `
            -ErrorAction Stop

        Write-Host "Assigned security group: $GroupName"
    }

    $GroupsAssigned = $true

    Write-Host "Group assignment operations completed."
}
catch {
    Write-Warning "PARTIAL PROVISIONING: $EmployeeName"
    Write-Warning "Account created: $AccountCreated"
    Write-Warning "Group assignment error: $($_.Exception.Message)"
    Write-Warning "Review the account and its memberships before retrying."
    throw
}


# Independently verify the provisioned account
Write-Host "`nVerifying provisioning results..."

$VerifiedUser = Get-MgUser `
    -UserId $NewUser.Id `
    -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
    -ErrorAction Stop

if ($VerifiedUser.UserPrincipalName -ne $NewUserUPN) {
    throw "VERIFICATION FAILED: User Principal Name mismatch."
}

if ($VerifiedUser.AccountEnabled -ne $false) {
    throw "VERIFICATION FAILED: Account is not disabled."
}

# Read actual security group memberships

# Allow time for newly assigned memberships to become visible
$ActualGroups = @()

for ($Attempt = 1; $Attempt -le 5; $Attempt++) {

    $ActualGroups = @(
        Get-MgUserMemberOfAsGroup `
            -UserId $NewUser.Id `
            -All `
            -ErrorAction Stop
    )


$MissingGroups = @(
    foreach ($GroupName in $RequiredGroups) {
        $ExpectedGroup = @(
            Get-MgGroup `
                -Filter "displayName eq '$GroupName'" `
                -All `
                -ErrorAction Stop
        )

        if ($ExpectedGroup.Count -ne 1) {
            $GroupName
        }
        elseif ($ExpectedGroup[0].Id -notin $ActualGroups.Id) {
            $GroupName
        }
    }
)

    if ($MissingGroups.Count -eq 0) {
        break
    }

    if ($Attempt -lt 5) {
        Write-Host "Waiting for group membership synchronization..."
        Start-Sleep -Seconds 3
    }
}

# Verify each required group using its unique ID
foreach ($GroupName in $RequiredGroups) {

    $ExpectedGroup = @(
        Get-MgGroup `
            -Filter "displayName eq '$GroupName'" `
            -All `
            -ErrorAction Stop
    )

    if ($ExpectedGroup.Count -ne 1) {
        throw "VERIFICATION FAILED: Group '$GroupName' is missing or ambiguous."
    }

    if ($ExpectedGroup[0].Id -notin $ActualGroups.Id) {
        throw "VERIFICATION FAILED: Missing membership in '$GroupName'."
    }
}

$ProvisioningComplete = $true

Write-Host "Account verification: PASSED"
Write-Host "Account disabled: CONFIRMED"
Write-Host "Required group memberships: VERIFIED"
Write-Host "Provisioning status: COMPLETE - PENDING ACTIVATION"




}
else {
    Write-Host "Action: DRY RUN - No changes made"
}

} # End of onboarding request loop

