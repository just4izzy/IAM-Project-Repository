# Northstar Financial Services — IAM Test Results

## Test 001: Finance Analyst Read-Only Access

**Test Status:** PASS  
**Test User:** Avery Stone  
**Environment:** Microsoft Entra ID, Microsoft 365, SharePoint Online

### 1. Objective

Validate role-based access control (RBAC) by configuring a Microsoft Entra ID security group and assigning read-only permissions to a test user through SharePoint Online.

The purpose of this test was to ensure that a Finance Analyst could access and view financial documents without having permission to edit or delete them.

### 2. Configuration

The following components were configured:

- **Test User:** Avery Stone
- **Job Role:** Finance Analyst
- **Security Group:** `SG-FIN-READ`
- **SharePoint Site:** Northstar Finance
- **SharePoint Permission Group:** Northstar Finance Visitors
- **Test Resource:** Microsoft Word document created within the Finance SharePoint site

The `SG-FIN-READ` security group was added to the Northstar Finance Visitors group, which grants read-only access to the site.

Avery Stone was then added as a member of `SG-FIN-READ`.

### 3. Expected Results

After configuring the group memberships and SharePoint permissions, Avery Stone should be able to:

- Access the Northstar Finance SharePoint site.
- Open and view the test Word document.
- Read the document without modifying its contents.
- Be prevented from editing or deleting the document.

### 4. Actual Results

| Test Action | Expected Result | Actual Result | Status |
|---|---|---|---|
| Access Finance SharePoint site | Allowed | Allowed | PASS |
| View Word document | Allowed | Allowed | PASS |
| Edit Word document | Denied | Denied | PASS |
| Delete Word document | Denied | Denied | PASS |

**Additional Observation:**

Avery Stone was presented with the option to request elevated access. However, the account did not automatically receive additional permissions. Elevated access would require approval and an appropriate permission change.

### 5. Conclusion

**Test Result: PASS — 4/4 checks successful**

The RBAC configuration functioned as intended during testing.

Avery Stone was able to access and view the financial document but could not edit or delete it.

This test demonstrated successful implementation of group-based access control and the principle of least privilege for the tested SharePoint resource.

### 6. Future Testing

- Validate access revocation after removing Avery Stone from `SG-FIN-READ`.
- Configure and test Finance Manager editing permissions.
- Verify that other group memberships do not grant unintended access.

&nbsp;
---
&nbsp;

## Test 002: Finance Manager Edit Access

### 1. Objective

Validate role-based access control (RBAC) by granting a Finance Manager permission to view, edit, and delete financial documents through Microsoft Entra ID security groups and SharePoint Online.

The purpose of this test was to verify that Finance Managers receive additional permissions compared to Finance Analysts.

### 2. Configuration

The following components were configured:

- **Test User:** Jordan Mitchell
- **Department:** Finance
- **Job Role:** Finance Manager
- **Security Group:** `SG-FIN-EDIT`
- **SharePoint Site:** Northstar Finance
- **SharePoint Permission Group:** Northstar Finance Members
- **Permission Level:** Edit
- **Test Resource:** Financial Word document

The `SG-FIN-EDIT` security group was added to the Northstar Finance Members SharePoint group.

Jordan Mitchell was then added to `SG-FIN-EDIT`, granting access through group membership rather than individual permission assignments.

### 3. Expected Results

After configuring the group memberships and SharePoint permissions, Jordan Mitchell should be able to:

- Access the Northstar Finance SharePoint site.
- Open and view financial documents.
- Edit and save changes to documents.
- Delete documents.
- Restore deleted documents from the SharePoint Recycle Bin.

### 4. Actual Results

| Test Action | Expected Result | Actual Result | Status |
|---|---|---|---|
| Access Finance SharePoint site | Allowed | Allowed | PASS |
| View financial document | Allowed | Allowed | PASS |
| Edit financial document | Allowed | Allowed | PASS |
| Delete financial document | Allowed | Allowed | PASS |
| Restore deleted document | Allowed | Allowed | PASS |

**Additional Verification:**

SharePoint's **Check Permissions** feature confirmed that Jordan Mitchell received the `Edit` permission level through the Northstar Finance Members group.

The financial document was also confirmed to inherit permissions from its parent SharePoint site.

**Troubleshooting Observation:**

During initial testing, document deletion appeared to be restricted to the file owner.

Further testing confirmed that Jordan Mitchell could successfully delete and restore both the original financial document and a separate disposable test document.

The cause of the initial deletion message was not determined.

### 5. Conclusion

**Test Result: PASS — 5/5 checks successful**

The Finance Manager RBAC configuration functioned as intended.

Jordan Mitchell successfully accessed, viewed, edited, deleted, and restored documents within the Northstar Finance SharePoint site.

This test demonstrated that different security groups can provide different permission levels to the same business resource.

Together with Test 001, these results validate the intended distinction between Finance Analyst read-only access and Finance Manager Edit access for the tested documents.

### 6. Future Testing

- Test access revocation after removing a user from a security group.
- Simulate promoting a Finance Analyst to Finance Manager.
- Verify that previous group memberships are removed during role changes.
- Validate effective permissions after employee transfers.

&nbsp;
---
&nbsp;

## Test 003: HR Specialist Access Validation

### 1. Objective

Validate role-based access control (RBAC) by granting an HR Specialist
Edit permissions to HR documents while restricting access to Finance
resources.

The purpose of this test was to verify departmental access separation
and enforce the principle of least privilege.

### 2. Configuration

The following components were configured:

- **Test User:** Olivia Bennett
- **Department:** Human Resources
- **Job Role:** HR Specialist
- **Security Group:** `SG-HR-EDIT`
- **SharePoint Site:** Northstar HR
- **SharePoint Permission Group:** Northstar HR Members
- **Permission Level:** Edit
- **Test Resource:** HR Employee Records test document

Olivia Bennett was added to the `SG-HR-EDIT` security group.

The security group was added to the Northstar HR Members SharePoint
group, granting access through group membership rather than
individual permission assignments.

### 3. Expected Results

Olivia Bennett should be able to:

- Access the Northstar HR SharePoint site.
- View HR documents.
- Edit and save changes to HR documents.
- Delete disposable HR test documents.
- Be denied access to the Northstar Finance SharePoint site.

### 4. Actual Results

| Test Action | Expected Result | Actual Result | Status |
|---|---|---|---|
| Access Northstar HR site | Allowed | Allowed | PASS |
| View HR test document | Allowed | Allowed | PASS |
| Edit and save HR document | Allowed | Allowed | PASS |
| Delete HR test document | Allowed | Allowed | PASS |
| Access Northstar Finance site | Denied | Denied | PASS |

### 5. Conclusion

**Test Result: PASS — 5/5 checks successful**

The HR Specialist RBAC configuration functioned as intended.

Olivia Bennett successfully accessed, viewed, edited, and deleted
documents within the Northstar HR SharePoint site.

Olivia was also denied access to the Northstar Finance SharePoint
site.

This test demonstrated successful group-based access control,
least-privilege access, and departmental access separation
for the tested resources.

### 6. Future Testing

- Verify that Finance employees cannot access HR resources.
- Test HR access revocation.
- Validate employee transfers between departments.
- Investigate additional restrictions for sensitive HR records.

&nbsp;
---
&nbsp;

## Test 004: Sales Department RBAC Validation

### 1. Objective

Validate role-based access control (RBAC) for two Sales employees
with different permission requirements.

Verify that Sales employees can access their assigned resources
without receiving unauthorized access to Finance or HR.

### 2. Configuration

**Sales Representative**
- Test User: Christopher Oneil
- Security Group: `SG-SALES-READ`
- SharePoint Group: Northstar Sales Visitors
- Permission Level: Read

**Sales Manager**
- Test User: Roger Pratt
- Security Group: `SG-SALES-EDIT`
- SharePoint Group: Northstar Sales Members
- Permission Level: Edit

**Resource:** Northstar Sales SharePoint site

### 3. Expected Results

- Sales Representatives can view documents but cannot edit or delete them.
- Sales Managers can view, edit, and delete documents.
- Neither role should have access to Finance or HR resources.

### 4. Actual Results

| Test Action | Christopher Oneil | Roger Pratt |
|---|---|---|
| View Sales documents | PASS - Allowed | PASS - Allowed |
| Edit Sales documents | PASS - Denied | PASS - Allowed |
| Delete Sales documents | PASS - Denied | PASS - Allowed |
| Access Finance site | PASS - Denied | PASS - Denied |
| Access HR site | PASS - Denied | PASS - Denied |

### 5. Conclusion

**Test Result: PASS**

Both Sales accounts demonstrated their expected role-based
permissions.

Christopher Oneil received read-only access, while Roger Pratt
received Edit access.

Both accounts were restricted from accessing the Finance and HR
SharePoint sites during testing.

These results demonstrate successful departmental access
separation and least-privilege configuration for the tested
resources.

### 6. Future Testing

- Validate access revocation.
- Test employee promotions between Sales roles.
- Verify access changes during departmental transfers.

&nbsp;
---
&nbsp;

## Test 005: IT Support RBAC Validation

### 1. Objective

Validate that an IT Support Specialist can access and manage
IT documentation without receiving unnecessary access to
other departmental resources.

### 2. Configuration

- **Test User:** Noah Carter
- **Department:** IT
- **Job Role:** IT Support Specialist
- **Security Group:** `SG-IT-EDIT`
- **SharePoint Site:** Northstar IT
- **SharePoint Group:** Northstar IT Members
- **Permission Level:** Edit

Noah Carter was added to the `SG-IT-EDIT` security group,
which was granted Edit access through Northstar IT Members.

### 3. Expected Results

- Access Northstar IT SharePoint.
- View, edit, and delete IT documents.
- Be denied access to HR, Finance, and Sales sites.

### 4. Actual Results

| Test Action | Expected | Actual | Status |
|---|---|---|---|
| Access Northstar IT | Allowed | Allowed | PASS |
| View IT documents | Allowed | Allowed | PASS |
| Edit IT documents | Allowed | Allowed | PASS |
| Delete IT documents | Allowed | Allowed | PASS |
| Access Northstar HR | Denied | Denied | PASS |
| Access Northstar Finance | Denied | Denied | PASS |
| Access Northstar Sales | Denied | Denied | PASS |

### 5. Conclusion

**Test Result: PASS — 7/7 checks successful**

The IT Support RBAC configuration functioned as intended.

Noah Carter received Edit permissions for Northstar IT
resources while being restricted from HR, Finance, and Sales
SharePoint sites during testing.

This demonstrated least-privilege access and departmental
access separation for the tested resources.

### 6. Future Testing

- Test employee role changes and access revocation.
- Validate IT access removal during offboarding.
- Explore least-privilege administrative role assignments
  separately from SharePoint permissions.

&nbsp;
---
&nbsp;


## Test 006: Joiner Lifecycle Management

### 1. Objective

Validate the employee onboarding (Joiner) process by provisioning
a new identity in Microsoft Entra ID and assigning access based
on the organization's RBAC entitlement matrix.

Verify that the employee receives only the permissions required
for their assigned job role.

### 2. Business Scenario

Northstar Financial Services hires a new Finance Analyst.

A simulated HR onboarding request specifies that the employee
requires read-only access to Finance documents.

**New Employee Details:**

- **Employee:** Taylor Morgan
- **Department:** Finance
- **Job Role:** Finance Analyst
- **Security Group:** `SG-FIN-READ`
- **Required Permission:** Read
- **Target Resource:** Northstar Finance SharePoint

### 3. Provisioning Process

1. Reviewed the simulated onboarding request.
2. Identified the appropriate security group using the RBAC matrix.
3. Created Taylor Morgan's account in Microsoft Entra ID.
4. Verified that the account could authenticate but could not
   access Northstar Finance before group assignment.
5. Added Taylor Morgan to `SG-FIN-READ`.
6. Verified Finance access after group assignment.
7. Tested document permissions and departmental access restrictions.

### 4. Test Results

| Test Action | Expected | Actual | Status |
|---|---|---|---|
| Finance access before group assignment | Denied | Denied | PASS |
| Finance access after group assignment | Allowed | Allowed | PASS |
| View Finance document | Allowed | Allowed | PASS |
| Edit Finance document | Denied | Denied | PASS |
| Delete Finance document | Denied | Denied | PASS |
| Access HR SharePoint | Denied | Denied | PASS |

### 5. Conclusion

**Test Result: PASS — 6/6 checks successful**

Taylor Morgan was successfully provisioned with the access
required for the Finance Analyst role.

Before security group assignment, the account could not access
Northstar Finance.

After joining `SG-FIN-READ`, the account received read-only
access to Finance documents while remaining restricted from
editing, deleting, and accessing the HR SharePoint site.

This test demonstrated successful identity provisioning,
group-based authorization, and least-privilege access
validation during the Joiner lifecycle.

### 6. Future Testing

- Automate user provisioning using Microsoft Graph PowerShell.
- Test employee role changes through the Mover lifecycle.
- Test access revocation through the Leaver lifecycle.
- Document account and entitlement changes for auditing.

&nbsp;
---
&nbsp;

## Test 007: Mover Lifecycle Management

### 1. Objective

Validate the employee transfer (Mover) process by updating
an existing employee's identity attributes and access permissions.

Ensure that the employee receives access appropriate for their
new role while losing access associated with their previous role.

### 2. Business Scenario

Avery Stone transfers from Finance to Human Resources.

**Previous Position:**
- Department: Finance
- Job Title: Finance Analyst
- Security Group: `SG-FIN-READ`
- SharePoint Access: Northstar Finance (Read)

**New Position:**
- Department: Human Resources
- Job Title: HR Specialist
- Security Group: `SG-HR-EDIT`
- SharePoint Access: Northstar HR (Edit)

The employee's previous Finance access must be revoked as
part of the transfer.

### 3. Implementation

1. Updated Avery Stone's Department to Human Resources.
2. Updated the Job Title to HR Specialist.
3. Removed Avery from `SG-FIN-READ`.
4. Added Avery to `SG-HR-EDIT`.
5. Signed in using Avery's account to validate permissions.
6. Reviewed group memberships to confirm the expected access.

All changes were performed manually through Microsoft Entra ID.

### 4. Test Results

| Test Action | Expected | Actual | Status |
|---|---|---|---|
| Department updated | Human Resources | Human Resources | PASS |
| Job title updated | HR Specialist | HR Specialist | PASS |
| Remove old Finance group | Removed | Removed | PASS |
| Add new HR group | Added | Added | PASS |
| Access HR SharePoint | Allowed | Allowed | PASS |
| Edit HR documents | Allowed | Allowed | PASS |
| Access Finance SharePoint | Denied | Denied | PASS |
| Verify group memberships | Correct | Correct | PASS |

### 5. Conclusion

**Test Result: PASS — 8/8 checks successful**

Avery Stone was successfully transferred from Finance Analyst
to HR Specialist.

The employee's identity attributes and security group
memberships were updated to reflect the new role.

Testing confirmed that Avery gained HR Edit access and lost
her previous Finance access.

This demonstrated manual access revocation, entitlement
reconciliation, and least-privilege enforcement during the
Mover lifecycle.

### 6. Future Testing

- Automate role changes using Microsoft Graph PowerShell.
- Test transfers involving multiple security groups.
- Validate access propagation and potential delays.
- Implement logging and approval verification for role changes.

&nbsp;
---
&nbsp;

## Test 008: Leaver Lifecycle Management

### 1. Objective

Validate the employee offboarding (Leaver) process by disabling
an employee's identity, revoking sign-in sessions, and removing
departmental security group memberships.

Ensure that a departing employee can no longer authenticate
or retain assigned access to company resources.

### 2. Business Scenario

Taylor Morgan, a Finance Analyst at Northstar Financial Services,
is leaving the organization.

A simulated HR termination request requires IT to revoke
the employee's access.

**Employee Details:**

- **Employee:** Taylor Morgan
- **Department:** Finance
- **Job Role:** Finance Analyst
- **Security Group:** `SG-FIN-READ`
- **Resource:** Northstar Finance SharePoint site
- **Offboarding Type:** Simulated termination

### 3. Implementation

The following actions were performed manually:

1. Located Taylor Morgan in Microsoft Entra ID.
2. Disabled the employee's account.
3. Revoked the employee's sign-in sessions.
4. Removed Taylor from `SG-FIN-READ`.
5. Attempted a new sign-in using a private browser.
6. Verified that `SG-FIN-READ` was no longer assigned.

The employee account was retained for future lab testing.

### 4. Test Results

| Test Action | Expected | Actual | Status |
|---|---|---|---|
| Disable Entra ID account | Disabled | Disabled | PASS |
| Revoke sign-in sessions | Action completed | Action completed | PASS |
| Remove Finance security group | Removed | Removed | PASS |
| Attempt new authentication | Blocked | Blocked | PASS |
| Verify Finance group removal | Absent | Absent | PASS |

### 5. Conclusion

**Test Result: PASS — 5/5 checks successful**

Taylor Morgan's account was successfully disabled,
sign-in sessions were revoked, and Finance security group
membership was removed.

A new authentication attempt was blocked, confirming
that the account could not establish a new sign-in session.

The employee's Finance entitlement was also verified
as removed.

This test demonstrated account deactivation,
session revocation, and entitlement removal during
the Leaver lifecycle.

Note: Existing access-token expiration and access
to external applications were not separately tested.

### 6. Future Testing

- Automate offboarding using Microsoft Graph PowerShell.
- Implement audit logging for account changes.
- Review application access and license reclamation.
- Test reactivation without restoring previous entitlements.

&nbsp;
---
&nbsp;


## Test 009: Excess Access Detection and Remediation

### 1. Objective

Validate that the Northstar RBAC Compliance Checker can
identify unauthorized security group memberships and
confirm successful remediation.

### 2. Business Scenario

Christopher Oneil, a Sales Representative, is accidentally
assigned access to Finance resources.

According to Northstar's RBAC entitlement matrix, Christopher
should only belong to `SG-SALES-READ`.

The additional `SG-FIN-READ` membership represents an
unauthorized entitlement.

### 3. Implementation

1. Confirmed Christopher's initial compliant access.
2. Added Christopher to `SG-FIN-READ` for testing.
3. Executed `Test-NorthStarRBACCompliance.ps1`.
4. Confirmed that the script reported `EXCESS ACCESS`.
5. Removed Christopher from `SG-FIN-READ`.
6. Ran the compliance checker again.
7. Verified that Christopher returned to `COMPLIANT`.

### 4. Test Results

| Test Action | Expected | Actual | Status |
|---|---|---|---|
| Initial access audit | COMPLIANT | COMPLIANT | PASS |
| Add unauthorized Finance group | Excess entitlement present | Present | PASS |
| Run compliance checker | EXCESS ACCESS | EXCESS ACCESS | PASS |
| Remove unauthorized Finance group | Removed | Removed | PASS |
| Run remediation verification | COMPLIANT | COMPLIANT | PASS |

### 5. Conclusion

**Test Result: PASS — 5/5 checks successful**

The Northstar RBAC Compliance Checker successfully identified
an unauthorized Finance security group membership assigned
to a Sales Representative.

After the unauthorized membership was removed, the script
confirmed that the employee's access returned to the
approved RBAC configuration.

This demonstrated automated entitlement reconciliation,
excess access detection, and remediation verification.

### 6. Future Improvements

- Add error handling for missing configuration files.
- Export compliance results to CSV.
- Detect missing required access through controlled testing.
- Expand auditing to additional employees and resources.

&nbsp;
---
&nbsp;


## Test 010 — Automated Joiner Provisioning

**Objective:** Validate automated employee onboarding using Microsoft Graph PowerShell and role-based access control.

**Test Identity:** Emma Wilson  
**Department:** Finance  
**Job Role:** Finance Analyst  
**Required Security Group:** SG-FIN-READ

### Procedure
1. Created a simulated, approved onboarding request in CSV format.
2. Executed the Joiner script in dry-run mode.
3. Validated the employee's role against the RBAC entitlement matrix.
4. Verified the proposed UPN was available.
5. Confirmed the required security group existed.
6. Executed the provisioning workflow using `-Execute`.
7. Created the employee account in a disabled state.
8. Assigned the employee to SG-FIN-READ.
9. Confirmed the account was disabled and assigned to the intended security group.

### Expected Result
- Employee account created successfully.
- Account remains disabled pending activation.
- Employee receives only the required Finance read-only security group.

### Actual Result
- Employee account created successfully.
- Account confirmed disabled.
- SG-FIN-READ membership confirmed.

**Result: PASS**

### Security Controls
- Default dry-run execution
- Explicit `-Execute` switch required for live provisioning
- Simulated onboarding approval validation
- Duplicate identity checks
- RBAC-driven group assignment
- Error handling for partial provisioning
- Post-provisioning account and group membership verification

**Limitations:** Approval was simulated through a CSV field. The workflow was tested in a lab environment and is not a production HR integration.
