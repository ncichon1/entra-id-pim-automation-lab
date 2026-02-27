<#
.SYNOPSIS
Exports privileged role activity from Microsoft Entra ID using Microsoft Graph.

.DESCRIPTION
This script connects to Microsoft Graph using delegated permissions,
retrieves recent directory audit logs, filters for privileged role activity,
and exports the results to a timestamped CSV file.

.AUTHOR
Nicholas Cichon
#>

# Connect to Microsoft Graph
# ===============================

if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes `
        "AuditLog.Read.All",
        "RoleManagement.Read.Directory",
        "Directory.Read.All"
}

Write-Host "Connected to Microsoft Graph."

# Retrieve Audit Logs
# ===============================

Write-Host "Retrieving directory audit logs..."

$logs = Get-MgAuditLogDirectoryAudit -Top 50

# Filter Privileged Activity
# ===============================

$privilegedLogs = $logs | Where-Object {
    $_.ActivityDisplayName -like "*role*" -or
    $_.ActivityDisplayName -like "*Global*"
}

# Select Relevant Properties
# ===============================

$report = $privilegedLogs | Select-Object `
    ActivityDateTime,
    ActivityDisplayName,
    Result,
    InitiatedBy

# Display Results
# ===============================

Write-Host "Displaying filtered privileged activity..."
$report | Format-Table -AutoSize

# Export to CSV
# ===============================

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$filename = "Privileged_Audit_Report_$timestamp.csv"

$report | Export-Csv -Path $filename -NoTypeInformation

Write-Host "Report exported successfully to $filename"
