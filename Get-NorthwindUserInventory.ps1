<#
    Get-NorthwindUserInventory.ps1
    Read-only user access inventory - Northwind Botanicals IAM Governance Lab
    Controls: NIST 800-53 AC-2, AU-6 | NIST CSF ID.AM-03, PR.AA-01 | ISO 27001 A.5.16, A.8.15
    Prerequisite: Connect-MgGraph with Directory.Read.All
#>

$OutputFolder = "$HOME\Documents\NorthwindLab\evidence"
if (-not (Test-Path $OutputFolder)) { New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null }
$stamp   = Get-Date -Format "yyyy-MM-dd_HHmm"
$csvPath = Join-Path $OutputFolder "user-inventory_$stamp.csv"

if (-not (Get-MgContext)) { Write-Host "Not connected. Run Connect-MgGraph first." -ForegroundColor Red; return }

$users = Get-MgUser -All -Property "displayName,userPrincipalName,accountEnabled,department,jobTitle,createdDateTime,id" |
    Select-Object DisplayName, UserPrincipalName, AccountEnabled, Department, JobTitle, CreatedDateTime

$users | Sort-Object Department, DisplayName |
    Format-Table DisplayName, Department, JobTitle, AccountEnabled -AutoSize

$total    = $users.Count
$disabled = ($users | Where-Object { -not $_.AccountEnabled }).Count
Write-Host ""
Write-Host "Total accounts   : $total"    -ForegroundColor Cyan
Write-Host "Disabled accounts: $disabled" -ForegroundColor Yellow

$users | Sort-Object Department, DisplayName | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "Saved: $csvPath" -ForegroundColor Green