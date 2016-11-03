Get-NotificationSubscription | foreach {
 $ns = $_.DisplayName
 $_.ToRecipients | foreach {
  If ($_.Name -match "ECHO-IMS NOC") {
   Write-Host $ns
  }
 }
}