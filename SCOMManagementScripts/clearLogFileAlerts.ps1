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
#first capture the reference time which is 10 min before this script ran
#  and must be in UTC
$timenow=get-date
$timenowutc=$timenow.touniversaltime()
$reftime = $timenowutc.addminutes(-8)
write-host "REFERENCE TIME" $reftime
#reference time is compared to event raised time- NOT last modified.  If you compare
#against last modified there's the possibility of a continuous loop.
get-Alert | where {$_.customfield1 -eq "AUTO_CLEAR_THIS" -and $_.ResolutionState -ne 255 -and $_.TimeRaised -lt $reftime } | resolve-alert

write-host "All logfile alerts originating before " $reftime " have been removed"