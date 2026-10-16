
# ============================================================
# Northstar Financial Services
# Automated Mover Workflow - Version 2
#
# Default: DRY RUN
# Live execution: .\Move-NorthstarEmployee.ps1 -Execute
#
# Requires Microsoft Graph PowerShell and appropriate
# delegated permissions / Entra directory privileges.
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
$RequestPath = Join-Path $ProjectRoot "requests\mover-requests.csv"

$TenantDomain = "IzzysITLab.onmicrosoft.com"

foreach ($Path in @($RBACPath, $RequestPath)) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file not found: $Path"
    }
}

$RBAC = @(Import-Csv -LiteralPath $RBACPath)
$Requests = @(Import-Csv -LiteralPath $RequestPath)

if ($RBAC.Count -eq 0 -or $Requests.Count -eq 0) {
    throw "RBAC matrix or Mover requests file is empty."
}

# ------------------------------------------------------------
# 2. Verify Microsoft Graph connection
# ------------------------------------------------------------

$Context = Get-MgContext

if (-not $Context) {
    throw "Not connected to Microsoft Graph."
}

if (-not $Context.Account) {
    throw "Microsoft Graph connection has no account."
}

if ($Execute) {

    # Protect against unintended bulk modifications.
    if ($Requests.Count -ne 1) {
        throw "Live execution requires exactly one Mover request."
    }

    $RequiredScopes = @(
        "User.ReadWrite.All"
        "GroupMember.ReadWrite.All"
    )

    foreach ($Scope in $RequiredScopes) {
        if ($Scope -notin $Context.Scopes) {
            throw "Missing Microsoft Graph scope: $Scope"
        }
    }
}

# ------------------------------------------------------------
# 3. Helper: Resolve RBAC security groups
# ------------------------------------------------------------

function Resolve-NorthstarGroup {

    param(
        [Parameter(Mandatory)]
        [string]$GroupName
    )

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
        throw "'$GroupName' is not a security group."
    }

    if ("DynamicMembership" -in @($Group.GroupTypes)) {
        throw "'$GroupName' uses dynamic membership."
    }

    return $Group
}

# ------------------------------------------------------------
# 4. Helper: Read current RBAC group memberships
# ------------------------------------------------------------

function Get-NorthstarMemberships {

    param(
        [Parameter(Mandatory)]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string[]]$ManagedGroupIds
    )

    $Memberships = @(
        Get-MgUserMemberOfAsGroup `
            -UserId $UserId `
            -All `
            -ErrorAction Stop
    )

    return @(
        $Memberships |
            Where-Object { $_.Id -in $ManagedGroupIds }
    )
}

# ------------------------------------------------------------
# 5. Process Mover requests
# ------------------------------------------------------------

foreach ($Request in $Requests) {

    Write-Host ""
    Write-Host "======================================="
    Write-Host "Northstar Automated Mover"
    Write-Host "======================================="

    if ($Request.ApprovalStatus -ne "Approved") {
        Write-Warning "Request not approved. Skipping."
        continue
    }

    if ([string]::IsNullOrWhiteSpace($Request.UserPrincipalName) -or
        [string]::IsNullOrWhiteSpace($Request.NewDepartment) -or
        [string]::IsNullOrWhiteSpace($Request.NewJobRole)) {
        throw "Mover request contains missing required values."
    }

    # Restrict the workflow to the Northstar lab tenant.
    $ExpectedSuffix = "@$TenantDomain"

    if (-not $Request.UserPrincipalName.EndsWith(
        $ExpectedSuffix,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "User is outside the approved Northstar tenant domain."
    }

    # --------------------------------------------------------
    # 6. Retrieve and validate employee
    # --------------------------------------------------------

    $User = Get-MgUser `
        -UserId $Request.UserPrincipalName `
        -Property Id,UserPrincipalName,DisplayName,Department,JobTitle,AccountEnabled `
        -ErrorAction Stop

    if ($User.AccountEnabled -ne $true) {
        throw "Employee account is disabled. Manual review required."
    }

    Write-Host "Account status validation: PASSED"

    # --------------------------------------------------------
    # 7. Validate current and target roles
    # --------------------------------------------------------

    $CurrentRules = @(
        $RBAC | Where-Object {
            $_.Department -eq $User.Department -and
            $_.JobRole -eq $User.JobTitle -and
            $_.Status -eq "Implemented"
        }
    )

    if ($CurrentRules.Count -eq 0) {
        throw "Current employee role is not defined in RBAC."
    }

    Write-Host "Current role validation: PASSED"

    $NewRules = @(
        $RBAC | Where-Object {
            $_.Department -eq $Request.NewDepartment -and
            $_.JobRole -eq $Request.NewJobRole -and
            $_.Status -eq "Implemented"
        }
    )

    if ($NewRules.Count -eq 0) {
        throw "Target role is not implemented in RBAC."
    }

    if ($User.Department -eq $Request.NewDepartment -and
        $User.JobTitle -eq $Request.NewJobRole) {
        throw "Employee already has the requested department and role."
    }

    $ExpectedCurrentGroups = @(
        $CurrentRules |
            Select-Object -ExpandProperty SecurityGroup -Unique
    )

    $RequiredGroups = @(
        $NewRules |
            Select-Object -ExpandProperty SecurityGroup -Unique
    )

    $ManagedGroupNames = @(
        $RBAC |
            Where-Object { $_.Status -eq "Implemented" } |
            Select-Object -ExpandProperty SecurityGroup -Unique
    )

    # --------------------------------------------------------
    # 8. Resolve all managed groups and their object IDs
    # --------------------------------------------------------

    $ResolvedGroups = @{}

    foreach ($GroupName in $ManagedGroupNames) {

        $Group = Resolve-NorthstarGroup -GroupName $GroupName

        $ResolvedGroups[$GroupName] = $Group.Id
    }

    $ManagedGroupIds = @(
        $ResolvedGroups.Values
    )

    $ExpectedCurrentIds = @(
        $ExpectedCurrentGroups |
            ForEach-Object { $ResolvedGroups[$_] }
    )

    $RequiredGroupIds = @(
        $RequiredGroups |
            ForEach-Object { $ResolvedGroups[$_] }
    )

    # --------------------------------------------------------
    # 9. Validate current RBAC memberships
    # --------------------------------------------------------

    $CurrentMemberships = @(
        Get-NorthstarMemberships `
            -UserId $User.Id `
            -ManagedGroupIds $ManagedGroupIds
    )

    $CurrentGroupIds = @(
        $CurrentMemberships |
            Select-Object -ExpandProperty Id
    )

    $MissingGroups = @(
        $ExpectedCurrentIds |
            Where-Object { $_ -notin $CurrentGroupIds }
    )

    $UnexpectedGroups = @(
        $CurrentGroupIds |
            Where-Object { $_ -notin $ExpectedCurrentIds }
    )

    if ($MissingGroups.Count -gt 0 -or
        $UnexpectedGroups.Count -gt 0) {
        throw "Current RBAC memberships do not match policy. Manual review required."
    }

    Write-Host "Current access validation: PASSED"
    Write-Host "Group ID validation: PASSED"

    # --------------------------------------------------------
    # 10. Calculate required changes using object IDs
    # --------------------------------------------------------

    $GroupsToRemove = @(
        $ExpectedCurrentGroups |
            Where-Object { $_ -notin $RequiredGroups }
    )

    $GroupsToAdd = @(
        $RequiredGroups |
            Where-Object { $_ -notin $ExpectedCurrentGroups }
    )

    Write-Host ""
    Write-Host "Employee: $($User.DisplayName)"
    Write-Host "Current Department: $($User.Department)"
    Write-Host "Current Role: $($User.JobTitle)"
    Write-Host "New Department: $($Request.NewDepartment)"
    Write-Host "New Role: $($Request.NewJobRole)"

    Write-Host ""
    Write-Host "Groups to REMOVE: $($GroupsToRemove -join ', ')"
    Write-Host "Groups to ADD: $($GroupsToAdd -join ', ')"

    # --------------------------------------------------------
    # 11. Default dry-run behavior
    # --------------------------------------------------------

    if (-not $Execute) {

        Write-Host ""
        Write-Host "Action: DRY RUN - No changes made"
        continue
    }

    # --------------------------------------------------------
    # 12. Revalidate immediately before making changes
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Action: LIVE EXECUTION REQUESTED"

    $FreshUser = Get-MgUser `
        -UserId $User.Id `
        -Property Id,Department,JobTitle,AccountEnabled `
        -ErrorAction Stop

    if ($FreshUser.AccountEnabled -ne $true -or
        $FreshUser.Department -ne $User.Department -or
        $FreshUser.JobTitle -ne $User.JobTitle) {
        throw "Employee state changed since validation. Aborting."
    }

    $FreshMemberships = @(
        Get-NorthstarMemberships `
            -UserId $User.Id `
            -ManagedGroupIds $ManagedGroupIds
    )

    $FreshGroupIds = @(
        $FreshMemberships | Select-Object -ExpandProperty Id
    )

    if (@($FreshGroupIds | Where-Object {
        $_ -notin $ExpectedCurrentIds
    }).Count -gt 0 -or
        @($ExpectedCurrentIds | Where-Object {
        $_ -notin $FreshGroupIds
    }).Count -gt 0) {

        throw "RBAC memberships changed since validation. Aborting."
    }

    Write-Host "Pre-execution validation: PASSED"

    # --------------------------------------------------------
    # 13. Execute access transition
    # --------------------------------------------------------

    $RemovedGroups = @()
    $AddedGroups = @()
    $ProfileUpdateAttempted = $false

    try {

        # Remove obsolete access first to avoid overlapping
        # permissions during the role transition.

        foreach ($GroupName in $GroupsToRemove) {

            $GroupId = $ResolvedGroups[$GroupName]

            Write-Host "Removing: $GroupName"

            Remove-MgGroupMemberByRef `
                -GroupId $GroupId `
                -DirectoryObjectId $User.Id `
                -ErrorAction Stop

            $RemovedGroups += $GroupName
        }

        # Assign the access required by the new job role.

        foreach ($GroupName in $GroupsToAdd) {

            $GroupId = $ResolvedGroups[$GroupName]

            Write-Host "Adding: $GroupName"

            $MemberReference = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
            }

            New-MgGroupMemberByRef `
                -GroupId $GroupId `
                -BodyParameter $MemberReference `
                -ErrorAction Stop

            $AddedGroups += $GroupName
        }

        # Update the employee's identity attributes.

        Write-Host "Updating employee department and job title"

        $ProfileUpdateAttempted = $true

        Update-MgUser `
            -UserId $User.Id `
            -Department $Request.NewDepartment `
            -JobTitle $Request.NewJobRole `
            -ErrorAction Stop

        # ----------------------------------------------------
        # 14. Verify final state
        # ----------------------------------------------------

        $VerifiedUser = Get-MgUser `
            -UserId $User.Id `
            -Property Department,JobTitle,AccountEnabled `
            -ErrorAction Stop

        if ($VerifiedUser.AccountEnabled -ne $true -or
            $VerifiedUser.Department -ne $Request.NewDepartment -or
            $VerifiedUser.JobTitle -ne $Request.NewJobRole) {

            throw "Employee profile verification failed."
        }

        $VerifiedMemberships = @(
            Get-NorthstarMemberships `
                -UserId $User.Id `
                -ManagedGroupIds $ManagedGroupIds
        )

        $VerifiedGroupIds = @(
            $VerifiedMemberships | Select-Object -ExpandProperty Id
        )

        $MissingFinal = @(
            $RequiredGroupIds |
                Where-Object { $_ -notin $VerifiedGroupIds }
        )

        $UnexpectedFinal = @(
            $VerifiedGroupIds |
                Where-Object { $_ -notin $RequiredGroupIds }
        )

        if ($MissingFinal.Count -gt 0 -or
            $UnexpectedFinal.Count -gt 0) {

            throw "Final RBAC membership verification failed."
        }

        Write-Host ""
        Write-Host "======================================="
        Write-Host "MOVER COMPLETED SUCCESSFULLY"
        Write-Host "======================================="
        Write-Host "Employee: $($User.DisplayName)"
        Write-Host "New Role: $($Request.NewJobRole)"
        Write-Host "New Department: $($Request.NewDepartment)"
        Write-Host "Final RBAC verification: PASSED"

    }
    catch {

        $OriginalError = $_

        Write-Warning "Mover execution failed."
        Write-Warning $OriginalError.Exception.Message
        Write-Warning "Attempting to restore the original account state."

        # ----------------------------------------------------
        # 15. Best-effort recovery
        # ----------------------------------------------------

        # Read the current state again. This also accounts for
        # an API operation that succeeded before reporting an error.

        try {

            $RecoveryMemberships = @(
                Get-NorthstarMemberships `
                    -UserId $User.Id `
                    -ManagedGroupIds $ManagedGroupIds
            )

            $RecoveryIds = @(
                $RecoveryMemberships |
                    Select-Object -ExpandProperty Id
            )

            # Remove target-role groups that were not part
            # of the original role.

            foreach ($GroupName in $GroupsToAdd) {

                $GroupId = $ResolvedGroups[$GroupName]

                if ($GroupId -in $RecoveryIds) {

                    Remove-MgGroupMemberByRef `
                        -GroupId $GroupId `
                        -DirectoryObjectId $User.Id `
                        -ErrorAction Stop
                }
            }

            # Restore original role memberships if missing.

            $RecoveryMemberships = @(
                Get-NorthstarMemberships `
                    -UserId $User.Id `
                    -ManagedGroupIds $ManagedGroupIds
            )

            $RecoveryIds = @(
                $RecoveryMemberships |
                    Select-Object -ExpandProperty Id
            )

            foreach ($GroupName in $GroupsToRemove) {

                $GroupId = $ResolvedGroups[$GroupName]

                if ($GroupId -notin $RecoveryIds) {

                    $MemberReference = @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
                    }

                    New-MgGroupMemberByRef `
                        -GroupId $GroupId `
                        -BodyParameter $MemberReference `
                        -ErrorAction Stop
                }
            }

            if ($ProfileUpdateAttempted) {

                Update-MgUser `
                    -UserId $User.Id `
                    -Department $User.Department `
                    -JobTitle $User.JobTitle `
                    -ErrorAction Stop
            }

            Write-Warning "Recovery actions submitted. Verify the account manually."

        }
        catch {

            Write-Warning "Recovery also encountered an error:"
            Write-Warning $_.Exception.Message
            Write-Warning "URGENT: Manual access review required."
        }

        throw "Mover failed. Check group memberships and employee attributes before retrying."
    }
}
