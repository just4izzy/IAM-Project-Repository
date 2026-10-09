# Northstar Financial Services

## 1. About the Organization

Northstar Financial Services is a fictional financial services company I'm using to practice enterprise Identity and Access Management (IAM).

The organization will simulate approximately 75 employees across multiple departments, with different job roles, responsibilities, and access requirements.

## 2. Project Objective

Design, implement, and test an identity management system that assigns employees appropriate access based on their job roles and responsibilities.

The project will focus on:

- Role-Based Access Control (RBAC)
- Microsoft Entra ID user and group management
- SharePoint Online permissions
- Principle of least privilege
- Employee onboarding, role changes, and offboarding
- Future automation using PowerShell and Microsoft Graph

## 3. Organizational Structure

The following departments and job roles will be used to simulate a realistic enterprise environment.

| Department | Job Role | Business Resource |
|---|---|---|
| Finance | Finance Analyst | Financial reports |
| Finance | Finance Manager | Financial reports and approvals |
| Human Resources | HR Specialist | Employee records |
| Sales | Sales Representative | Customer information |
| Operations | Operations Coordinator | Operational procedures |
| IT | Help Desk Administrator | IT documentation |
| Executives | Executive | Management reports |
| Contractors | Project Contractor | Assigned project files |

## 4. Access Control Design

Northstar will use Microsoft Entra ID security groups to manage access to business resources.

Instead of assigning permissions individually to each employee, users will be added to security groups based on their job responsibilities.

These groups will be assigned permissions to resources such as SharePoint Online sites.

This design aims to simplify permission management and enforce the principle of least privilege.

### Example: Finance Department

A Finance Analyst requires read-only access to financial reports.

To implement this:

1. Create the `SG-FIN-READ` security group in Microsoft Entra ID.
2. Add the security group to the Northstar Finance Visitors SharePoint group.
3. Add the Finance Analyst's account to `SG-FIN-READ`.
4. Verify that the user can view financial documents without editing or deleting them.

## 5. Current Implementation

The following components have been implemented and tested:

- Created the Northstar Finance SharePoint site.
- Created the `SG-FIN-READ` security group.
- Created Avery Stone as a fictional Finance Analyst.
- Assigned Avery Stone to `SG-FIN-READ`.
- Granted the security group SharePoint Read permissions through the Visitors group.
- Successfully tested document viewing, editing restrictions, and deletion restrictions.

All four access-control checks passed.

Detailed testing documentation is available in `test-results.md`.

## 6. Next Steps

- Create the RBAC entitlement matrix.
- Define additional security groups for other job roles.
- Implement and test Finance Manager permissions.
- Test access revocation when an employee changes roles.
- Expand the IAM environment to additional departments.
- Develop Joiner-Mover-Leaver automation using PowerShell and Microsoft Graph.
