

**# Automated Joiner Workflow**



**## Overview**



**Northstar Financial Services implemented an automated Joiner workflow using Microsoft Entra ID, Microsoft Graph PowerShell, and Role-Based Access Control (RBAC).**



**The workflow provisions new employee identities based on approved onboarding requests and assigns security group memberships according to an established RBAC entitlement matrix.**



**## Technologies Used**



**- Microsoft Entra ID**

**- Microsoft Graph PowerShell SDK**

**- Microsoft 365 / SharePoint Online**

**- PowerShell**

**- CSV-based request processing**

**- Role-Based Access Control (RBAC)**



**## Business Objective**



**Reduce manual identity provisioning tasks while ensuring that new employees receive only the access required for their job responsibilities.**



**The workflow supports the principle of least privilege by deriving group assignments from predefined role-based policies.**



**## Workflow**



**1. Import the onboarding request from `joiner-requests.csv`.**

**2. Validate that the onboarding request is approved.**

**3. Validate the requested department and job role against the RBAC entitlement matrix.**

**4. Check whether the employee account already exists.**

**5. Validate the proposed User Principal Name (UPN).**

**6. Identify the security groups required for the employee's role.**

**7. Provision the employee account in Microsoft Entra ID.**

**8. Configure the account as disabled until activation is separately authorized.**

**9. Assign the required RBAC security groups.**

**10. Verify the account status and assigned group memberships.**



**## Security Controls**



**- Dry-run mode enabled by default.**

**- Live provisioning requires the explicit `-Execute` parameter.**

**- Only approved requests are processed.**

**- Group assignments are derived from the RBAC entitlement matrix.**

**- Existing accounts are checked to prevent duplicate provisioning.**

**- Newly provisioned accounts remain disabled.**

**- Provisioning results are verified using Microsoft Graph.**



**## Test Scenario**



**\*\*Test Employee:\*\* Emma Wilson**



**\*\*Department:\*\* Finance**



**\*\*Job Role:\*\* Finance Analyst**



**\*\*Required Security Group:\*\* `SG-FIN-READ`**



**\*\*Expected Permissions:\*\* Read-only access to the Northstar Finance SharePoint site.**



**## Test Results**



**The automated Joiner workflow successfully:**



**- Validated Emma Wilson's onboarding request.**

**- Confirmed the requested role existed in the RBAC entitlement matrix.**

**- Checked the proposed user identity.**

**- Created the employee account in Microsoft Entra ID.**

**- Assigned the `SG-FIN-READ` security group.**

**- Verified the employee account was disabled.**

**- Verified the assigned group membership.**



**\*\*Result: PASSED\*\***



**## Limitations**



**This workflow was developed as a controlled IAM lab simulation.**



**The CSV approval field simulates HR authorization rather than an integrated HR approval process.**



**Employee account activation, production-grade audit logging, automated approvals, and broader error recovery are outside the current implementation.**



**## Lessons Demonstrated**



**This workflow demonstrates:**



**- Identity lifecycle management**

**- Automated user provisioning**

**- Role-Based Access Control**

**- Least-privilege access assignment**

**- Microsoft Graph administration**

**- PowerShell automation**

**- Identity provisioning validation**



