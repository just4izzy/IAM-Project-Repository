
# ============================================================
# Northstar Financial Services
# Automated Leaver Workflow - Version 1
#
# Default: DRY RUN
# Live: .\Disable-NorthstarLeaver.ps1 -Execute
#
# Test employee: Christopher Oneil
# ============================================================

[CmdletBinding()]
param(
    [switch]$Execute
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# 1. Configuration
# ------------------------------------------------------------

$ProjectRoot = Split-Path $PSScriptRoot -Parent

$RBACPath = Join-Path $ProjectRoot "config\rbac-entitlement-matrix.csv"
$RequestPath = Join-Path $ProjectRoot "requests\leaver-requests.csv"

# Restrict the initial live test to Christopher.
$AllowedUser = "christopher.oneil@IzzysITLab.onmicrosoft.com"

# Expected current state after the Mover workflow.
$ExpectedDepartment = "Sales"
$ExpectedJobTitle = "Sales Manager"
$ExpectedGroup = "SG-SALES-EDIT"

foreach ($Path in @($RBACPath, $RequestPath)) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file missing: $Path"
    }
}

$RBAC = @(Import-Csv -LiteralPath $RBACPath)
$Requests = @(Import-Csv -LiteralPath $RequestPath)

if ($RBAC.Count -eq 0 -or $Requests.Count -ne 1) {
    throw "RBAC must contain rules and the request file must contain exactly one row."
}

# ------------------------------------------------------------
# 2. Validate Microsoft Graph connection
# ------------------------------------------------------------

$Context = Get-MgContext

if (-not $Context) {
    throw "Connect to Microsoft Graph before running this script."
}

$RequiredScopes = @(
    "User.ReadWrite.All"
    "GroupMember.ReadWrite.All"
)

if ($Execute) {
    foreach ($Scope in $RequiredScopes) {
        if ($Scope -notin $Context.Scopes) {
            throw "Missing Microsoft Graph permission: $Scope"
        }
    }
}

# ------------------------------------------------------------
# 3. Validate offboarding request
# ------------------------------------------------------------

$Request = $Requests[0]

Write-Host ""
Write-Host "======================================="
Write-Host "Northstar Automated Leaver"
Write-Host "======================================="

if ($Request.ApprovalStatus -ne "Approved") {
    throw "Offboarding request is not approved."
}

if ($Request.UserPrincipalName -ne $AllowedUser) {
    throw "This lab script is restricted to Christopher Oneil."
}

Write-Host "Request approval validation: PASSED"

# ------------------------------------------------------------
# 4. Retrieve employee
# ------------------------------------------------------------

$User = Get-MgUser `
    -UserId $Request.UserPrincipalName `
    -Property Id,DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled `
    -ErrorAction Stop

if ($User.UserPrincipalName -ne $AllowedUser) {
    throw "Retrieved employee does not match the approved test account."
}

if ($User.AccountEnabled -ne $true) {
    throw "Employee is already disabled. Manual review required."
}

if ($User.Department -ne $ExpectedDepartment -or
    $User.JobTitle -ne $ExpectedJobTitle) {
    throw "Employee attributes do not match the expected test state."
}

Write-Host "Employee identity validation: PASSED"

# ------------------------------------------------------------
# 5. Identify Northstar-managed security groups
# ------------------------------------------------------------

$ManagedGroupNames = @(
    $RBAC |
        Where-Object { $_.Status -eq "Implemented" } |
        Select-Object -ExpandProperty SecurityGroup -Unique
)

if ($ExpectedGroup -notin $ManagedGroupNames) {
    throw "Expected group is missing from the RBAC matrix."
}

$ManagedGroupIds = @()
$ResolvedGroups = @{}

foreach ($GroupName in $ManagedGroupNames) {

    $EscapedName = $GroupName.Replace("'", "''")

    $Matches = @(
        Get-MgGroup `
            -Filter "displayName eq '$EscapedName'" `
            -All `
            -Property Id,DisplayName,SecurityEnabled,GroupTypes `
            -ErrorAction Stop
    )

    if ($Matches.Count -ne 1) {
        throw "Expected exactly one group named '$GroupName'."
    }

    $Group = $Matches[0]

    if ($Group.SecurityEnabled -ne $true) {
        throw "Group '$GroupName' is not a security group."
    }

    if ("DynamicMembership" -in @($Group.GroupTypes)) {
        throw "Group '$GroupName' uses dynamic membership."
    }

    $ResolvedGroups[$GroupName] = $Group.Id
    $ManagedGroupIds += $Group.Id
}

Write-Host "RBAC group validation: PASSED"

# ------------------------------------------------------------
# 6. Validate actual group memberships
# ------------------------------------------------------------

$CurrentMemberships = @(
    Get-MgUserMemberOfAsGroup `
        -UserId $User.Id `
        -All `
        -ErrorAction Stop
)

$RBACMemberships = @(
    $CurrentMemberships |
        Where-Object { $_.Id -in $ManagedGroupIds }
)

$RBACGroupIds = @(
    $RBACMemberships | Select-Object -ExpandProperty Id
)

$ExpectedGroupId = $ResolvedGroups[$ExpectedGroup]

if ($RBACGroupIds.Count -ne 1 -or
    $ExpectedGroupId -notin $RBACGroupIds) {

    throw "Current RBAC memberships do not match the expected Sales Manager role."
}

Write-Host "Current access validation: PASSED"

# ------------------------------------------------------------
# 7. Display offboarding plan
# ------------------------------------------------------------

Write-Host ""
Write-Host "Employee: $($User.DisplayName)"
Write-Host "Department: $($User.Department)"
Write-Host "Job Title: $($User.JobTitle)"
Write-Host "Account Enabled: $($User.AccountEnabled)"
Write-Host "Reason: $($Request.Reason)"

Write-Host ""
Write-Host "Planned actions:"
Write-Host "1. Disable employee account"
Write-Host "2. Revoke sign-in sessions"
Write-Host "3. Remove Northstar RBAC group memberships"
Write-Host "4. Verify final account state"

Write-Host ""
Write-Host "Groups to REMOVE: $($RBACMemberships.DisplayName -join ', ')"

# ------------------------------------------------------------
# 8. Dry-run protection
# ------------------------------------------------------------

if (-not $Execute) {

    Write-Host ""
    Write-Host "Action: DRY RUN - No changes made"
    return
}

# ------------------------------------------------------------
# 9. Revalidate before live execution
# ------------------------------------------------------------

Write-Host ""
Write-Host "Action: LIVE EXECUTION REQUESTED"

$FreshUser = Get-MgUser `
    -UserId $User.Id `
    -Property Id,Department,JobTitle,AccountEnabled `
    -ErrorAction Stop

if ($FreshUser.AccountEnabled -ne $true -or
    $FreshUser.Department -ne $ExpectedDepartment -or
    $FreshUser.JobTitle -ne $ExpectedJobTitle) {

    throw "Employee state changed before execution. Aborting."
}

$FreshMemberships = @(
    Get-MgUserMemberOfAsGroup `
        -UserId $User.Id `
        -All `
        -ErrorAction Stop
)

$FreshRBACIds = @(
    $FreshMemberships |
        Where-Object { $_.Id -in $ManagedGroupIds } |
        Select-Object -ExpandProperty Id
)

if ($FreshRBACIds.Count -ne 1 -or
    $ExpectedGroupId -notin $FreshRBACIds) {

    throw "RBAC memberships changed before execution. Aborting."
}

Write-Host "Pre-execution validation: PASSED"

# ------------------------------------------------------------
# 10. Disable employee account
# ------------------------------------------------------------

try {

    Write-Host ""
    Write-Host "Disabling employee account..."

    Update-MgUser `
        -UserId $User.Id `
        -AccountEnabled:$false `
        -ErrorAction Stop

    # Verify account disabled before other modifications.

    $DisabledUser = Get-MgUser `
        -UserId $User.Id `
        -Property AccountEnabled `
        -ErrorAction Stop

    if ($DisabledUser.AccountEnabled -ne $false) {
        throw "Account disable verification failed."
    }

    Write-Host "Account disabled: VERIFIED"

    # --------------------------------------------------------
    # 11. Revoke sign-in sessions
    # --------------------------------------------------------

    Write-Host "Revoking sign-in sessions..."

    $RevokeResult = Revoke-MgUserSignInSession `
        -UserId $User.Id `
        -ErrorAction Stop

    if ($null -ne $RevokeResult -and
        $null -ne $RevokeResult.Value -and
        $RevokeResult.Value -eq $false) {

        throw "Microsoft Graph reported session revocation failure."
    }

    Write-Host "Session revocation: REQUEST ACCEPTED"

    # --------------------------------------------------------
    # 12. Remove RBAC memberships
    # --------------------------------------------------------

    foreach ($Membership in $RBACMemberships) {

        Write-Host "Removing group: $($Membership.DisplayName)"

        Remove-MgGroupMemberByRef `
            -GroupId $Membership.Id `
            -DirectoryObjectId $User.Id `
            -ErrorAction Stop
    }

    # --------------------------------------------------------
    # 13. Verify final state
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Verifying offboarding..."

    $Verified = $false

    for ($Attempt = 1; $Attempt -le 5; $Attempt++) {

        $VerifiedUser = Get-MgUser `
            -UserId $User.Id `
            -Property AccountEnabled `
            -ErrorAction Stop

        $FinalMemberships = @(
            Get-MgUserMemberOfAsGroup `
                -UserId $User.Id `
                -All `
                -ErrorAction Stop
        )

        $RemainingRBAC = @(
            $FinalMemberships |
                Where-Object { $_.Id -in $ManagedGroupIds }
        )

        if ($VerifiedUser.AccountEnabled -eq $false -and
            $RemainingRBAC.Count -eq 0) {

            $Verified = $true
            break
        }

        Start-Sleep -Seconds 3
    }

    if (-not $Verified) {
        throw "Final account or RBAC membership verification failed."
    }

    Write-Host ""
    Write-Host "======================================="
    Write-Host "LEAVER COMPLETED SUCCESSFULLY"
    Write-Host "======================================="
    Write-Host "Employee: $($User.DisplayName)"
    Write-Host "Account Enabled: False"
    Write-Host "RBAC Groups Remaining: 0"
    Write-Host "Session Revocation: Requested"
    Write-Host "Final Verification: PASSED"

}
catch {

    Write-Warning "OFFBOARDING INCOMPLETE"
    Write-Warning $_.Exception.Message
    Write-Warning "Account and memberships require manual review."
    Write-Warning "Do not assume all offboarding steps succeeded."

    throw
}
