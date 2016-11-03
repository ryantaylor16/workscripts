#v1.1.0WDH
echo "Starting Resolve_SQLjobAlerts.ps1" | out-File c:\SCOMManagementScripts\testout.txt -append
#First execute c:\windows\system32\windowspowershell\v1.0\powershell.exe
#Second, start ops mgr snapin via this script

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
$reftime = $timenowutc.addminutes(-60)
write-host "REFERENCE TIME" $reftime | out-File c:\testout.txt
#reference time is compared to event raised time- NOT last modified.  If you compare
#against last modified there's the possibility of a continuous loop.

#v1 get-alert | where {$_.ResolutionState -ne 255 -and $_.Name -eq 'A SQL job failed to complete successfully' -and $_.TimeRaised -lt $reftime } | resolve-alert
#v2 get-alert | where-object {$_.ResolutionState -lt 41 -and $_.TimeRaised -lt $reftime -and $_.Name -match "^(IS Package Failed|Log Backup Failed to Complete|A SQL job failed to complete successfully|Long Running Jobs|IS Service failed to load user defined Configuration file)"} | resolve-alert
get-alert | where-object {$_.ResolutionState -lt 41 -and $_.TimeRaised -lt $reftime -and $_.Name -match "^(IS Package Failed|Could not open device|Backup device failed - Operating system error|Log Backup Failed to Complete|A SQL job (failed|has failed) to complete successfully|Long Running Jobs|IS Service failed to load user defined Configuration file)"} | resolve-alert
write-host "All sql job alerts originating before " $reftime " have been removed"