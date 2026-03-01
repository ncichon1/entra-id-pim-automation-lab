param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath
)

# Ensure logs folder exists
if (-not (Test-Path ".\logs")) {
    New-Item -ItemType Directory -Path ".\logs" | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = ".\logs\offboarding_batch_$timestamp.txt"

function Write-Log {
    param([string]$Message)
    $entry = "$(Get-Date -Format "u") - $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Host $Message
}

Write-Log "Connecting to Microsoft Graph..."

Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

$terminatedUsers = Import-Csv $CsvPath

foreach ($u in $terminatedUsers) {

    try {

        Write-Log "Processing termination: $($u.UserPrincipalName)"

        $user = Get-MgUser -Filter "userPrincipalName eq '$($u.UserPrincipalName)'" -ErrorAction SilentlyContinue

        if (-not $user) {
            Write-Log "User not found. Skipping."
            continue
        }

        # Disable account
        Update-MgUser -UserId $user.Id -AccountEnabled:$false
        Write-Log "Account disabled."

        # Revoke active sessions
        Revoke-MgUserSignInSession -UserId $user.Id
        Write-Log "Active sessions revoked."

        # Remove from all security groups
        $groups = Get-MgUserMemberOf -UserId $user.Id -All | Where-Object {
            $_.'@odata.type' -eq "#microsoft.graph.group"
        }

        foreach ($group in $groups) {
            try {
                Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
                Write-Log "Removed from group: $($group.DisplayName)"
            }
            catch {
                Write-Log "Could not remove from group: $($group.DisplayName)"
            }
        }

        Write-Log "Termination completed successfully."

    }
    catch {
        Write-Log "ERROR during termination: $_"
    }
}
