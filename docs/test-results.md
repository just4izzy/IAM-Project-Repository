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
