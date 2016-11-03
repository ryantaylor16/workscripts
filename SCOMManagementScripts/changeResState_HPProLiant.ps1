#########################################
#  changeResState_HPProLiant.ps1	#
#					#
#  Author:  Carl W. Funk		#
#					#
#  Purpose:  Change all SIM alerts  	#
#	that are warning to		#
#       State 'IT Windows Support'      #
#					#
#					#
#########################################

echo "Starting changeResState_SQLjobAlerts.ps1" | out-File c:\SCOMManagementScripts\testout.txt -append

#First execute c:\windows\system32\windowspowershell\v1.0\powershell.exe
#Second, start ops mgr snapin via this script

#Set variable for the RMS
$rootMS = 'wdhpmnscom01'

#Initialize the opsmgr powershell provider

add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client" -ErrorVariable errSnapin ;
set-location "OperationsManagerMonitoring::" -ErrorVariable errSnapin ;
new-managementGroupConnection -ConnectionString:$rootMS -ErrorVariable errSnapin ;
set-location $rootMS -ErrorVariable errSnapin ;

# Gather all the HP proliant warning alerts in 'new' state
$alerts = get-alert | where-object {$_.MonitoringObjectFullName -match "^HewlettPackard.Servers.ProLiant" -and $_.severity -eq "warning" -and $_.resolutionstate -eq 0}

# Now that we have our alerts, let's change the resolution state to our custom one.
foreach ($alert in $alerts) {
# Change resolution
$resState=10 #IT Windows Support
$alert.ResolutionState=$resState
Update the RMS
$alert.Update("")
}
