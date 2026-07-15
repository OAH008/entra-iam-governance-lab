$domain = "northwindbotanicals.onmicrosoft.com"

$funcGroups = @(
  @{ Name="SG-IT-Admins";               Members=@("david.okafor","nina.petrova") }
  @{ Name="SG-Finance-VendorEntry";     Members=@("kevin.alvarez") }
  @{ Name="SG-Finance-PaymentApproval"; Members=@("rebecca.lin") }
)

foreach ($fg in $funcGroups) {
  $existing = Get-MgGroup -Filter "displayName eq '$($fg.Name)'" -ErrorAction SilentlyContinue
  if ($existing) { Write-Host "Group exists: $($fg.Name)" -ForegroundColor Yellow; $gid = $existing.Id }
  else {
    $g = New-MgGroup -DisplayName $fg.Name -MailEnabled:$false `
         -MailNickname ($fg.Name -replace '[^a-zA-Z0-9]','') -SecurityEnabled:$true
    Write-Host "Created group: $($fg.Name)" -ForegroundColor Green; $gid = $g.Id
  }
  foreach ($m in $fg.Members) {
    $u = Get-MgUser -Filter "userPrincipalName eq '$m@$domain'"
    try { New-MgGroupMember -GroupId $gid -DirectoryObjectId $u.Id -ErrorAction Stop
          Write-Host "  + $m" -ForegroundColor Green }
    catch { Write-Host "  ($m already a member)" -ForegroundColor DarkGray }
  }
}
Write-Host "`nPhase 2 function groups done." -ForegroundColor Cyan