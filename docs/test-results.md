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
