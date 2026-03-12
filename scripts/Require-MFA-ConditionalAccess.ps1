# Phase 4 - MFA Enforcement via Conditional Access
Write-Host "Creating MFA Conditional Access policy..."

$params = @{
    DisplayName   = "Require MFA - All Users"
    State         = "enabledForReportingButNotEnforced"  # Report-Only first
    Conditions    = @{
        Users = @{
            IncludeUsers = @("All")
            ExcludeUsers = @($breakGlass.Id)
        }
        Applications = @{
            IncludeApplications = @("All")
        }
        ClientAppTypes = @("all")
    }
    GrantControls = @{
        Operator        = "OR"
        BuiltInControls = @("mfa")
    }
}

$policy = New-MgIdentityConditionalAccessPolicy -BodyParameter $params
Write-Host "Policy created in Report-Only mode: $($policy.Id)"
Write-Host "Validate in CA Insights workbook, then run Enable-MFA-Policy.ps1 to enforce."
