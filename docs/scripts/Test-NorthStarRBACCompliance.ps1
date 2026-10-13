
# Northstar Financial Services
# RBAC Compliance Checker - Version 2
# Read-only Microsoft Graph audit

# Import RBAC entitlement matrix
$RBACPath = Join-Path $PSScriptRoot "..\config\rbac-entitlement-matrix.csv"
$RBAC = Import-Csv $RBACPath

# Employees to audit
$Employees = @(
    "Avery Stone",
    "Jordan Mitchell",
    "Olivia Bennett",
    "Roger Pratt",
    "Christopher Oneil",
    "Taylor Morgan"
)

# Audit employee access
$Report = foreach ($EmployeeName in $Employees) {

    $User = Get-MgUser `
        -Filter "displayName eq '$EmployeeName'" `
        -Property Id,DisplayName,Department,JobTitle,AccountEnabled `
        -ErrorAction Stop

    if (-not $User) {
        Write-Warning "Employee not found: $EmployeeName"
        continue
    }

    # Find expected groups from RBAC matrix
    $ExpectedGroups = @(
        $RBAC | Where-Object {
            $_.JobRole -eq $User.JobTitle -and
            $_.Department -eq $User.Department -and
            $_.Status -eq "Implemented"
        } | Select-Object -ExpandProperty SecurityGroup
    )

    # Retrieve actual group memberships
    $ActualGroups = @(
        Get-MgUserMemberOfAsGroup -UserId $User.Id -All `
            -ErrorAction Stop |
        Select-Object -ExpandProperty DisplayName
    )

    # Filter Northstar security groups
    $NorthstarGroups = @(
        $ActualGroups | Where-Object {
            $_ -like "SG-*"
        }
    )

    # Find missing and excess access
    $Missing = @(
        $ExpectedGroups | Where-Object {
            $_ -notin $NorthstarGroups
        }
    )

    $Excess = @(
        $NorthstarGroups | Where-Object {
            $_ -notin $ExpectedGroups
        }
    )

    # Determine compliance status
    $Status = if ($User.AccountEnabled -eq $false) {
        if ($NorthstarGroups.Count -eq 0) {
            "DISABLED - ACCESS REMOVED"
        }
        else {
            "DISABLED - REVIEW GROUPS"
        }
    }
    elseif ($ExpectedGroups.Count -eq 0) {
        "REVIEW - NO RBAC RULE"
    }
    elseif ($Missing.Count -gt 0 -and $Excess.Count -gt 0) {
        "MISSING AND EXCESS ACCESS"
    }
    elseif ($Missing.Count -gt 0) {
        "MISSING ACCESS"
    }
    elseif ($Excess.Count -gt 0) {
        "EXCESS ACCESS"
    }
    else {
        "COMPLIANT"
    }

    # Create audit report
    [PSCustomObject]@{
        Employee   = $User.DisplayName
        Department = $User.Department
        Role       = $User.JobTitle
        Enabled    = $User.AccountEnabled
        Expected   = ($ExpectedGroups -join ", ")
        Actual     = ($NorthstarGroups -join ", ")
        Status     = $Status
    }
}

# Display audit results
$Report | Format-Table -AutoSize -Wrap
