#==========================================================================================================================
# AUTHOR:	Tao Yang 
# DATE:		05/08/2012
# Name:		Push-OM07SkypeNotification.PS1
# Version:	1.0
# COMMENT:	Remotely Execute Send-SkypeNotification.PS1 using PsExec.exe
# Usage:	.\Push-OM07SkypeNotification.PS1 -SkypeNode "SkypeNodeComputer" -SendScriptPath "C:\Scripts\Send-OM12SkypeNotification.PS1" -alertID xxxxx -Recipients "SkypeID#1;#SkypeID#2"
#==========================================================================================================================

Param (
	[string]$SkypeNode,
	[string]$SendScriptPath,
	[string]$AlertID,
	[String]$Recipients
)

Function Get-OSArchitecture($Computer)
{
	$objOS = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
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

Function Get-SkypeProcess($Computer)
{
	$SkypeProcess = Get-WmiObject -Query "SELECT * FROM Win32_Process WHERE Name = 'Skype.exe'" -ComputerName $SkypeNode
	$SkypeProcess
}

$RMS = "SCOM01"
$thisScript = $myInvocation.MyCommand.Path
$scriptRoot = Split-Path(Resolve-Path $thisScript)

#Firstly, Make Sure PsExec.exe is located on the same folder of this script
$PsExecPath = Join-Path $scriptRoot "PsExec.exe"
if (!(Test-Path $PsExecPath))
{
	Write-Error "Unable to locate PsExec.exe on `"$Scriptroot`"`!"
	Exit
}

#Secondly, Determine 32-bit PowerShell path on Skype Node computer
$SkypeNodeOSArch = Get-OSArchitecture $SkypeNode
If ($SkypeNodeOSArch -ieq "64-bit")
{
	$PSPath = "C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
} elseif ($SkypeNodeOSArch -ieq "32-bit") {
	$PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
} else {
	Write-Error "Unable to determine the OS Architecture of $SkypeNode`!"
	Exit
}

#Then obtain Skype.exe process information from Skype Node computer
$SkypeProcess = Get-SkypeProcess $SkypeNode
If ($SkypeProcess -eq $null)
{
	Write-Error "Skype is not running on $SkypeNode`!"
	Exit
}

If ($SkypeProcess -is [System.Array])
{
	Write-Error "Multiple isntances of Skype detected on $SkypeNode. Please make sure there is only 1 instance of Skype running!"
	Exit
}

$SkypeProcessSessionID = $SkypeProcess.SessionId

$strPushCmd = "$PsExecPath /accepteula -s \\$SkypeNode -i $SkypeProcessSessionID $PSPath $SendScriptPath -SCOMMgtServer $RMS -AlertID $AlertID -Recipients `'$Recipients`'"
Write-Host $strPushCmd
cmd /c $strPushCmd