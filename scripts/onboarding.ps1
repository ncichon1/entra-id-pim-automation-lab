# Bulk Onboarding Automation Script
# Requires Microsoft Graph PowerShell SDK
# Scopes: User.ReadWrite.All, Group.ReadWrite.All, Directory.ReadWrite.All

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath
)

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = ".\logs\onboarding_batch_$timestamp.txt"

function Write-Log {
    param([string]$Message)
    $entry = "$(Get-Date -Format "u") - $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Host $Message
}

Write-Log "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

$users = Import-Csv $CsvPath

foreach ($u in $users) {

    try {
    Write-Log "Processing: $($u.UserPrincipalName)"

    # Check if user already exists
    $existingUser = Get-MgUser -Filter "userPrincipalName eq '$($u.UserPrincipalName)'" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Log "User already exists. Skipping creation."
        continue
    }

    $passwordProfile = @{
        Password = "TempP@ssw0rd123!"
        ForceChangePasswordNextSignIn = $true
    }

        $newUser = New-MgUser `
            -DisplayName $u.DisplayName `
            -UserPrincipalName $u.UserPrincipalName `
            -MailNickname ($u.UserPrincipalName.Split("@")[0]) `
            -AccountEnabled `
            -PasswordProfile $passwordProfile `
            -Department $u.Department

        Write-Log "User created."

        # Assign group
        $group = Get-MgGroup -Filter "displayName eq '$($u.GroupName)'"
        if ($group) {
            New-MgGroupMemberByRef -GroupId $group.Id -BodyParameter @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($newUser.Id)"
            }
            Write-Log "Added to group: $($u.GroupName)"
        }
        else {
            Write-Log "Group not found: $($u.GroupName)"
        }

    }
    catch {
        Write-Log "ERROR for $($u.UserPrincipalName): $_"
    }
}

Write-Log "Batch onboarding complete."
