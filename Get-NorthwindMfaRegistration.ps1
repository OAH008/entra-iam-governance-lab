<#
    Get-NorthwindMfaRegistration.ps1
    ------------------------------------------------------------
    Read-only report of which accounts have a strong (MFA-capable)
    authentication method registered, and which do not. This is the
    report that established the "MFA not enforced / not registered"
    baseline finding (F-01).

    Control mapping:
      NIST 800-53  : IA-2, IA-2(1) (MFA)
      NIST CSF 2.0 : PR.AA-03 (Authentication)
      ISO 27001    : A.8.5 (Secure Authentication)

    Prerequisite: Connect-MgGraph with UserAuthenticationMethod.Read.All, Directory.Read.All
    ------------------------------------------------------------
#>

# --- Where the CSV evidence gets saved. Adjust this path to your own project folder. ---
$OutputFolder = "$HOME\Documents\NorthwindLab\evidence"
if (-not (Test-Path $OutputFolder)) { New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null }
$stamp   = Get-Date -Format "yyyy-MM-dd_HHmm"
$csvPath = Join-Path $OutputFolder "mfa-registration_$stamp.csv"

# --- Safety check: confirm we're connected before querying. ---
if (-not (Get-MgContext)) { Write-Host "Not connected. Run Connect-MgGraph first." -ForegroundColor Red; return }

# These are the authentication-method types that count as "strong" (i.e. real MFA).
# A password on its own is NOT in this list, so password-only accounts read as no-MFA.
$strong = @('microsoftAuthenticatorAuthenticationMethod','phoneAuthenticationMethod',
            'fido2AuthenticationMethod','softwareOathAuthenticationMethod',
            'windowsHelloForBusinessAuthenticationMethod')

# Step 1: get all users.
$users  = Get-MgUser -All -Property "displayName,userPrincipalName,id" | Select-Object DisplayName, UserPrincipalName, Id
$report = @()   # collector for the results

# Step 2: for each user, list their registered auth methods and decide if any qualify as MFA.
foreach ($u in $users) {
    $methods = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$($u.Id)/authentication/methods").value
    # turn each method into its short type name (e.g. "phoneAuthenticationMethod")
    $types   = $methods | ForEach-Object { ($_.'@odata.type' -replace '#microsoft.graph.','') }
    # true if the user has at least one method from the "strong" list above
    $hasMfa  = @($types | Where-Object { $strong -contains $_ }).Count -gt 0
    $report += [PSCustomObject]@{
        DisplayName       = $u.DisplayName
        UserPrincipalName = $u.UserPrincipalName
        MFARegistered     = $hasMfa
        MethodsRegistered = ($types -join '; ')
    }
}

# Step 3: display, count the gap, and export as evidence.
$report | Sort-Object MFARegistered, DisplayName | Format-Table DisplayName, MFARegistered, MethodsRegistered -AutoSize
$noMfa = @($report | Where-Object { -not $_.MFARegistered }).Count
Write-Host "`nAccounts WITHOUT registered MFA: $noMfa of $($report.Count)" -ForegroundColor Yellow
$report | Sort-Object MFARegistered, DisplayName | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "Saved: $csvPath" -ForegroundColor Green
