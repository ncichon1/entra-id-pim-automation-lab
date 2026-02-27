# Microsoft Entra ID PIM Automation Lab
## Overview
This project demonstrates a least-privilege Microsoft Entra ID architecture using Privileged Identity Management (PIM), role-assignable groups, Conditional Access, and Microsoft Graph PowerShell automation to monitor privileged activity.
The objective of this lab was to simulate a production-ready privileged access governance model with automated audit reporting.
---
## Architecture Implemented
- Break-glass Global Administrator account (excluded from Conditional Access) 
- Role-assignable privileged security group 
- Eligible Global Administrator role via PIM (Just-In-Time activation) 
- Conditional Access policy enforcement for privileged activation 
- Delegated Microsoft Graph authentication 
- Privileged activity monitoring and automated CSV reporting
--- 
## Privileged Access Workflow
1. User is added as **Eligible** to a role-assignable group
2. User activates Global Administrator via PIM (time-bound access) 
3. Conditional Access enforces security controls during activation 
4. Activity is logged in Entra ID directory audit logs 
5. PowerShell automation retrieves and exports privileged events
---
## Automation
The included PowerShell script:
- Connects to Microsoft Graph using delegated permissions 
- Retrieves recent directory audit logs 
- Filters privileged role activity 
- Selects relevant event properties 
- Exports a timestamped CSV audit report
--- ## Example Output
The script exports reports in the following format:
Privileged_Audit_Report_YYYY-MM-DD_HH-MM-SS.csv 
This enables repeatable audit generation and supports compliance review processes. 
--- 
## Technologies Used 
- Microsoft Entra ID 
- Privileged Identity Management (PIM) 
- Conditional Access 
- Microsoft Graph PowerShell SDK 
- PowerShell scripting 
--- 
## Author Nicholas Cichon
