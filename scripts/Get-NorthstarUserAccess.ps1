
# Northstar Financial Services
# User Access Audit - Microsoft Graph PowerShell
# Purpose: Retrieve employee information and direct group memberships
# Operations: Read-only

$EmployeeName = "{User's Name}"

# Retrieve the employee
$User = Get-MgUser `
    -Filter "displayName eq '$EmployeeName'" `
    -Property Id,DisplayName,Department,JobTitle,AccountEnabled

if (-not $User) {
    Write-Host "Employee not found: $EmployeeName"
    return
}

# Display employee information
Write-Host "`nEmployee Information"

$User |
    Select-Object DisplayName,Department,JobTitle,AccountEnabled |
    Format-List

# Retrieve direct security group memberships
Write-Host "Direct Group Memberships"

Get-MgUserMemberOfAsGroup -UserId $User.Id -All |
    Select-Object DisplayName
