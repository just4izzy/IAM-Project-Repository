
# Automated Leaver Workflow

## Overview

Northstar Financial Services implemented an automated Leaver workflow using Microsoft Entra ID, Microsoft Graph PowerShell, and Role-Based Access Control (RBAC).

The workflow supports employee offboarding by disabling accounts, requesting sign-in session revocation, and removing RBAC-managed security group memberships.

## Technologies Used

- Microsoft Entra ID
- Microsoft Graph PowerShell SDK
- PowerShell
- CSV-based request processing
- Role-Based Access Control (RBAC)

## Business Objective

Reduce the risk of unauthorized access after an employee leaves the organization.

The workflow helps enforce identity lifecycle policies by disabling departing employees' accounts and removing access associated with their previous job responsibilities.

## Workflow

1. Import an offboarding request from `leaver-requests.csv`.
2. Validate the request approval.
3. Confirm the employee's identity and current account status.
4. Resolve Northstar RBAC security groups.
5. Validate existing RBAC group memberships.
6. Display the proposed offboarding operations.
7. Revalidate account attributes and group memberships.
8. Disable the employee's Entra ID account.
9. Verify that the account is disabled.
10. Request revocation of sign-in sessions.
11. Remove the employee from Northstar RBAC-managed security groups.
12. Verify the account remains disabled and no Northstar RBAC memberships remain.

## Security Controls

- Dry-run mode enabled by default.
- Live execution requires the explicit `-Execute` parameter.
- Approved requests required.
- Test execution restricted to a designated lab employee.
- Employee identity and account status validated.
- RBAC-managed security groups resolved by object ID.
- Dynamic membership groups rejected.
- Account and memberships revalidated before execution.
- Account disabling occurs before group removal.
- Final account state and RBAC memberships verified.
- Execution failures trigger warnings requiring manual review.
- Failed offboarding does not automatically re-enable the employee.

## Test Scenario

**Employee:** Christopher Oneil

**Department:** Sales

**Job Role:** Sales Manager

**Current Security Group:** `SG-SALES-EDIT`

**Offboarding Reason:** Employment Termination

### Expected Changes

| Attribute | Before | After |
|-----------|--------|-------|
| Account enabled | True | False |
| SG-SALES-EDIT membership | Assigned | Removed |
| Session revocation | Not requested | Requested |
| Job title | Sales Manager | Sales Manager |

## Test Results

The automated Leaver workflow successfully:

- Validated the approved offboarding request.
- Verified Christopher's account and job attributes.
- Confirmed his existing RBAC access.
- Disabled the employee account.
- Submitted the sign-in session revocation request.
- Removed `SG-SALES-EDIT`.
- Verified that no Northstar RBAC-managed group memberships remained.
- Independently confirmed the account was disabled using Microsoft Graph.

**Result: PASSED**

## Limitations

This workflow is a controlled IAM lab simulation, not a production-ready employee termination system.

The approval field in the CSV simulates HR authorization.

Session revocation requests do not guarantee that all existing access tokens become invalid immediately.

The workflow does not automatically:

- Delete employee accounts.
- Remove Microsoft 365 licenses.
- Transfer OneDrive files or mailbox ownership.
- Remove permissions outside the Northstar RBAC matrix.
- Revoke access in unrelated third-party applications.
- Produce an immutable security audit log.

## Skills Demonstrated

- Identity lifecycle management
- Employee offboarding automation
- Microsoft Entra ID administration
- Microsoft Graph PowerShell
- Security group deprovisioning
- Access revocation
- Least-privilege enforcement
- Post-execution verification
- Error handling and security-focused workflow design
