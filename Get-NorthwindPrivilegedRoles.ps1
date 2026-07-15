<#
    Get-NorthwindPrivilegedRoles.ps1
    ------------------------------------------------------------
    Read-only report of every account holding an administrative
    (privileged) directory role in the tenant. This is the core
    "who has admin rights?" audit — the report that surfaced the
    external guest holding standing Global Administrator.

    Control mapping:
      NIST 800-53  : AC-2(7) (Privileged Accounts), AC-6 (Least Privilege), AU-6 (Audit Review)
      NIST CSF 2.0 : PR.AA-05, DE.CM
      ISO 27001    : A.8.2 (Privileged Access Rights)

    Prerequisite: Connect-MgGraph with Directory.Read.All (or RoleManagement.Read.Directory)
    ------------------------------------------------------------
#>

# --- Where the CSV evidence gets saved. Adjust this path to your own project folder. ---
$OutputFolder = "$HOME\Documents\NorthwindLab\evidence"
if (-not (Test-Path $OutputFolder)) { New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null }
$stamp   = Get-Date -Format "yyyy-MM-dd_HHmm"          # timestamp so each run is a distinct evidence file
$csvPath = Join-Path $OutputFolder "privileged-roles_$stamp.csv"

# --- Safety check: make sure we're actually connected to Graph before doing anything. ---
if (-not (Get-MgContext)) { Write-Host "Not connected. Run Connect-MgGraph first." -ForegroundColor Red; return }

$results = @()   # collector array for the final report rows

# Step 1: get every ACTIVATED directory role in the tenant.
# (Entra only "activates" a role once it's been used/assigned, so this returns the roles that matter.)
$roles = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directoryRoles").value

# Step 2: for each role, pull its members and record who holds it.
foreach ($role in $roles) {
    $members = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/directoryRoles/$($role.id)/members").value
    foreach ($m in $members) {
        $results += [PSCustomObject]@{
            Role              = $role.displayName
            MemberDisplayName = $m.displayName
            MemberUPN         = $m.userPrincipalName
            # strip Graph's type prefix so it just reads "user", "group", etc.
            MemberType        = ($m.'@odata.type' -replace '#microsoft.graph.','')
        }
    }
}

# Step 3: show the results on screen and export them as evidence.
if ($results.Count -eq 0) {
    Write-Host "No active directory role assignments found." -ForegroundColor Yellow
} else {
    $results | Sort-Object Role, MemberDisplayName | Format-Table -AutoSize
    Write-Host "`nTotal privileged assignments: $($results.Count)" -ForegroundColor Cyan
    $results | Sort-Object Role, MemberDisplayName | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "Saved: $csvPath" -ForegroundColor Green
}
