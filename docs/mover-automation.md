
# Automated Mover Workflow

## Overview

Northstar Financial Services implemented an automated Mover workflow using Microsoft Entra ID, Microsoft Graph PowerShell, and Role-Based Access Control (RBAC).

The workflow manages employee role changes by updating identity attributes and modifying security group memberships according to an established RBAC entitlement matrix.

## Technologies Used

- Microsoft Entra ID
- Microsoft Graph PowerShell SDK
- Microsoft 365 / SharePoint Online
- PowerShell
- CSV-based request processing
- Role-Based Access Control (RBAC)

## Business Objective

Automate employee transfers and promotions while preventing privilege accumulation.

When employees change roles, their previous role-based access should be removed and replaced with the access required for their new responsibilities.

## Workflow

1. Import the transfer request from `mover-requests.csv`.
2. Validate request approval.
3. Retrieve the employee from Microsoft Entra ID.
4. Confirm the employee account is enabled.
5. Validate the current and requested roles against the RBAC matrix.
6. Verify existing RBAC group memberships.
7. Calculate the groups that must be removed and added.
8. Resolve and validate the security group object IDs.
9. Revalidate employee attributes and memberships before execution.
10. Remove obsolete RBAC group memberships.
11. Assign the security groups required by the new role.
12. Update the employee's department and job title.
13. Verify the updated identity attributes and group memberships.

## Security Controls

- Dry-run mode enabled by default.
- Explicit `-Execute` parameter required for live execution.
- Approved requests required.
- Disabled employee accounts rejected.
- Current access validated before changes.
- RBAC-managed groups identified from the entitlement matrix.
- Security group object IDs used for membership modifications.
- Dynamic membership groups rejected.
- Pre-execution revalidation.
- Post-execution verification.
- Best-effort recovery if execution fails.

## Test Scenario

**Employee:** Christopher Oneil

**Previous Department:** Sales

**Previous Role:** Sales Representative

**New Department:** Sales

**New Role:** Sales Manager

### Expected Access Changes

| Action | Security Group | Access |
|--------|----------------|--------|
| Remove | `SG-SALES-READ` | Read-only |
| Add | `SG-SALES-EDIT` | Edit |

## Test Results

The automated Mover workflow successfully:

- Validated the approved transfer request.
- Verified Christopher's existing employee attributes.
- Confirmed current RBAC group memberships.
- Removed `SG-SALES-READ`.
- Added `SG-SALES-EDIT`.
- Updated the job title to Sales Manager.
- Verified the final RBAC memberships.
- Independently confirmed the updated identity attributes and group membership using Microsoft Graph.

**Result: PASSED**

## Limitations

This workflow was developed as a controlled IAM lab simulation.

Request approval is represented by a CSV field rather than an integrated HR authorization system.

Microsoft Graph changes are not transactional. Recovery is best-effort and may require manual intervention.

The workflow governs the security groups defined in the Northstar RBAC matrix. It does not automatically detect every possible source of access.

SharePoint Edit access was expected based on the configured RBAC permissions, but interactive SharePoint access was not separately retested after Christopher's promotion.

## Skills Demonstrated

- Identity lifecycle management
- Employee transfer automation
- Role-Based Access Control
- Least-privilege enforcement
- Privilege accumulation prevention
- Microsoft Graph PowerShell
- Security group management
- Access verification
- Error handling and recovery
