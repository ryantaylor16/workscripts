#=========================================================================================================================
# AUTHOR:	Tao Yang 
# DATE:		05/08/2012
# Name:		SkypeNotify07.PS1
# Version:	1.0
# COMMENT:	Retrieve OM07 alert and send alert details via Skype
# Usage:	.\SkypeNotify07.PS1 -SCOMMgtServer "SCOMServer" -alertID xxxxx -Recipients "SkypeID#1,#SkypeID#2"
#=========================================================================================================================

Param (
	[string]$SCOMMgtServer,
	[string]$AlertID,
	[string]$Recipients
)

Function Get-OSArchitecture
{
	$objOS = Get-WmiObject Win32_OperatingSystem
	If ($objOS.version -ge 6)
	{
		$OSarch = $objOS.OSArchitecture
	} else {
		if ($objOS.caption.contains("x64"))
		{
			$OSarch = "64-bit"
		} else {
			$OSarch = "32-bit"
		}
	}
	$OSarch
}

#Make sure this script is running under 32-bit PowerShell as Skype4COM API does not support 64-bit.
$OSArch = Get-OSArchitecture
$bIs32BitPS = $true
If ($OSarch -ieq "64-bit")
{
	if ($PSHOME -ine "C:\Windows\SysWOW64\WindowsPowerShell\v1.0")
	{
		$bIs32BitPS = $false
	}
}

if (!$bIs32BitPS)
{
	Write-Error "This script can only run under 32-bit PowerShell!"
	Exit
}

#Load OM07 PowerShell Snapin

if ((Get-PSSnapin | where-Object { $_.Name -eq 'Microsoft.EnterpriseManagement.OperationsManager.Client' }) -eq $null) 
{
	Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client -ErrorAction SilentlyContinue -ErrorVariable Err
}
if ((Get-PSDrive | where-Object { $_.Name -eq 'Monitoring' }) -eq $null)
{
	New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\ -ErrorAction SilentlyContinue -ErrorVariable Err | Out-Null
}

#Connect to RMS
Set-Location "OperationsManagerMonitoring::"
new-managementGroupConnection -ConnectionString:$SCOMMgtServer | Out-Null
Set-Location Monitoring:\$SCOMMgtServer

#Get Alert Details
$Alert = Get-Alert -Id $AlertID
$AlertName = $Alert.Name
$AlertTime = $Alert.TimeRaised
$AlertDescription = $Alert.Description
$AlertSeverity = $Alert.Severity
$AlertPriority = $Alert.Priority
$NotificationMessage = @"
SCOM Alert: $AlertName
UTC Time: $AlertTime
Severity: $AlertSeverity
Priority: $AlertPriority

Description:
$AlertDescription
"@

#Get Skype Recipients
$arrRecipients = @()
$arrRecipients += $Recipients.split(",")
#Send Skype Notification
$Skype = New-Object -ComObject Skype4Com.Skype
Foreach ($Recipient in $arrRecipients)
{
	Write-Host "Sending Notification to $Recipient`..."
	$chat = $Skype.CreateChatWith($Recipient)
	[Void]$chat.SendMessage($NotificationMessage)
}
