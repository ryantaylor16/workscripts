#======================================================================================================================
# AUTHOR:	Tao Yang 
# DATE:		05/08/2012
# Version:	1.0
# Comment:	Script to configure SCOM 2007 PowerShell Snapin for 32-Bit PowerShell
#======================================================================================================================
$ErrorActionPreference = "Stop"
Clear-Host
$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf
$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)


$Files = @("Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll-help.xml",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml",
           "Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml",
		   "Microsoft.EnterpriseManagement.OperationsManager.Common.dll",
           "Microsoft.EnterpriseManagement.OperationsManager.dll"
           )
		   


#Region Setup SCOM PS SnapIn
Write-Host "Configure Microsoft System Center Operations Manager (SCOM) 2007 R2 PowerShell SnapIn and SDK..." -ForegroundColor Yellow
$RootPath = Join-Path $env:ProgramFiles "System Center Operations Manager 2007\SnapIn"

#Create the snapin directory

If (!(Test-Path $rootPath))
{
	New-Item -type Directory -Path $rootPath -Force | Out-Null
}

#Copy Files
Write-Host "  - copying required files to $rootPath`..." -ForegroundColor Green
	foreach($file in $Files)
	{
		$FilePath = Join-Path $scriptRoot $file
		if(!(Test-Path (Join-Path $RootPath $File)))
		{ 
		  Copy-Item -Path $FilePath -Destination $RootPath | Out-Null
		}
		Remove-Variable FilePath
	}

#Writing Registry entries for SCOM PS SnapIn
Write-Host "  - Configuring SCOM PowerShell SnapIn Registry keys..." -ForegroundColor Green
  $hklm = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Env:COMPUTERNAME)
  $scom = $hklm.CreateSubKey("SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.EnterpriseManagement.OperationsManager.Client")
  $scom.SetValue("ApplicationBase",$RootPath,"String") | Out-Null
  $scom.SetValue("AssemblyName","Microsoft.EnterpriseManagement.OperationsManager.ClientShell, Version=6.0.4900.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35","String") | Out-Null
  $scom.SetValue("ModuleName","$RootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.dll","String") | Out-Null
  $scom.SetValue("PowerShellVersion","1.0","String") | Out-Null
  $scom.SetValue("Vendor","Microsoft Corporation","String") | Out-Null
  $scom.SetValue("Version","6.0.4900.0","String") | Out-Null
  $scom.SetValue("Description","Microsoft Operations Manager Shell Snapin","String") | Out-Null
  $scom.SetValue("Types","$RootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Types.ps1xml","String") | Out-Null
  $scom.SetValue("Formats","$RootPath\Microsoft.EnterpriseManagement.OperationsManager.ClientShell.Format.ps1xml","String") | Out-Null

#EndRegion
Write-Host ""
Write-Host "All Done!" -ForegroundColor Yellow