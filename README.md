
# Enterprise IAM Lifecycle Automation

### Microsoft Entra ID | Microsoft Graph | PowerShell | RBAC

## Project Overview

Northstar Financial Services is a fictional organization I created for my first hands-on Identity and Access Management (IAM) project.

The goal was to simulate how an organization manages employee identities, departmental access, and employee lifecycle events using Microsoft Entra ID.

I built a lab environment to configure and test Role-Based Access Control (RBAC), manage security group memberships, and implement Joiner, Mover, and Leaver (JML) automation.

The project combines hands-on identity administration, access testing, and PowerShell automation developed with AI assistance.

## Technologies Used

- Microsoft Entra ID
- Microsoft Graph PowerShell SDK
- Microsoft 365 Business Basic
- SharePoint Online
- Windows PowerShell
- GitHub
- CSV-based configuration and request files

## Lab Environment

Northstar Financial Services consists of fictional employees assigned to four departments:

- Finance
- Human Resources
- Sales
- Information Technology

Each department has a dedicated SharePoint Online site with permissions assigned through Microsoft Entra ID security groups.

An RBAC entitlement matrix defines which groups employees should receive based on their department and job role.

## Role-Based Access Control

| Department | Job Role | Security Group | Permission |
|------------|----------|----------------|------------|
| Finance | Finance Analyst | SG-FIN-READ | Read |
| Finance | Finance Manager | SG-FIN-EDIT | Edit |
| HR | HR Specialist | SG-HR-EDIT | Edit |
| Sales | Sales Representative | SG-SALES-READ | Read |
| Sales | Sales Manager | SG-SALES-EDIT | Edit |
| IT | IT Support | SG-IT-EDIT | Edit |

Security groups are mapped to SharePoint permissions to manage access without assigning permissions individually to each employee.

## Identity Lifecycle Management

The project implements three employee lifecycle workflows.

### 1. Joiner — Employee Onboarding

Automates the provisioning of new employee identities.

The workflow:

- Validates simulated HR onboarding approval.
- Checks for existing employee accounts.
- Determines required access from the RBAC matrix.
- Creates the employee in Microsoft Entra ID.
- Assigns the appropriate security groups.
- Verifies account creation and membership.

New accounts are provisioned in a disabled state pending separate activation.

**Test:** Emma Wilson was successfully provisioned as a Finance Analyst and assigned SG-FIN-READ.

### 2. Mover — Employee Role Changes

Automates employee promotions and transfers.

The workflow:

- Validates the approved role change.
- Confirms existing account attributes and permissions.
- Identifies required security group changes.
- Removes obsolete permissions.
- Assigns permissions required for the new role.
- Updates employee department and job title.
- Verifies the resulting account and group memberships.

**Test:** Christopher Oneil was promoted from Sales Representative to Sales Manager.

His SG-SALES-READ membership was removed and replaced with SG-SALES-EDIT.

### 3. Leaver — Employee Offboarding

Automates account deactivation and removal of managed access.

The workflow:

- Validates the approved offboarding request.
- Confirms employee identity and current permissions.
- Disables the employee account.
- Requests sign-in session revocation.
- Removes Northstar RBAC-managed group memberships.
- Verifies the final account state.

**Test:** Christopher Oneil's account was successfully disabled, and his managed RBAC memberships were removed.

## RBAC Compliance Auditing

I also developed a PowerShell compliance-checking workflow that compares employee security group memberships against the RBAC entitlement matrix.

The workflow identifies missing or unauthorized role-based access.

During testing, I intentionally assigned a Sales employee an unauthorized Finance security group.

The compliance checker detected the excess access, and I confirmed successful remediation after removing the unauthorized membership.

## Testing and Validation

The lab includes 12 documented test scenarios covering:

- Departmental SharePoint permissions
- Read versus Edit access
- Cross-department access restrictions
- Manual Joiner, Mover, and Leaver processes
- Excess access detection and remediation
- Automated Joiner provisioning
- Automated Mover role transitions
- Automated Leaver offboarding

**Result: All 12 documented test scenarios passed.**

See [Test Results](docs/test-results.md) for detailed procedures and outcomes.

## Automation Security Controls

The PowerShell workflows incorporate several safeguards:

- Dry-run mode by default
- Explicit `-Execute` parameter for live changes
- Simulated approval validation
- RBAC-driven group assignments
- Identity and membership checks
- Security group object ID validation
- Post-execution verification
- Error handling and manual-review warnings

These scripts were built for a controlled lab and are not presented as production-ready IAM automation.

## Project Limitations

Northstar is a simulated business environment.

The automation uses CSV files to represent HR requests and approvals rather than integrating with a production Human Capital Management (HCM) system.

The project does not implement a complete enterprise audit trail, approval system, privileged access governance, or automated access reviews.

The Leaver workflow requests session revocation but does not independently verify that every previously issued access token has expired.

## What I Learned

This project helped me gain practical experience with:

- Managing identities in Microsoft Entra ID
- Understanding how security group memberships control access
- Implementing least-privilege RBAC policies
- Managing Joiner, Mover, and Leaver scenarios
- Using Microsoft Graph PowerShell to query and modify identities
- Testing access permissions in SharePoint Online
- Investigating and remediating excess permissions
- Documenting IAM processes and testing results

I used AI assistance to help develop and troubleshoot parts of the PowerShell automation. I configured the lab, executed the workflows, and verified their behavior in Microsoft Entra ID.

Continuing to develop my independent PowerShell scripting skills is one of my next learning objectives.

## Project Status

**Core IAM lab implementation and JML automation completed.**

Documentation and repository organization are being finalized.
