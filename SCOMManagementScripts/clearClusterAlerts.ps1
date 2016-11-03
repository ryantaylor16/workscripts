#First execute c:\windows\system32\windowspowershell\v1.0\powershell.exe
#Second, start ops mgr snapin via this script

echo "starting clearClusterAlerts.ps1" | out-File c:\SCOMManagementScripts\testout.txt -append

#Set variable for the RMS
$rootMS = 'wdhpmnscom01'

#Initialize the opsmgr powershell provider

add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client" -ErrorVariable errSnapin ;
set-location "OperationsManagerMonitoring::" -ErrorVariable errSnapin ;
new-managementGroupConnection -ConnectionString:$rootMS -ErrorVariable errSnapin ;
set-location $rootMS -ErrorVariable errSnapin ;

#Start running the script
#first capture the reference time which is 30 min before this script ran
#  and must be in UTC
$timenow=get-date
$timenowutc=$timenow.touniversaltime()
$reftime = $timenowutc.addminutes(-30)
write-host "REFERENCE TIME" $reftime
#reference time is compared to event raised time- NOT last modified.  If you compare
#against last modified there's the possibility of a continuous loop.

get-alert | where {$_.ResolutionState -ne 255 -and $_.MonitoringObjectDisplayName -eq "Cluster Service" -and $_.IsMonitorAlert -eq 0 -and $_.TimeRaised -lt $reftime } | resolve-alert

write-host "All cluster alerts originating before " $reftime " have been removed"