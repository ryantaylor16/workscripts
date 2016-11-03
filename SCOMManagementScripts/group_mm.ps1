param($rootMS,$group,$numberOfHoursInMaintenanceMode,$comment)

Add-PSSnapin "Microsoft.EnterpriseManagement.OperationsManager.Client" -ErrorVariable errSnapin;
Set-Location "OperationsManagerMonitoring::" -ErrorVariable errSnapin;
new-managementGroupConnection -ConnectionString:$rootMS -ErrorVariable errSnapin;
set-location $rootMS -ErrorVariable errSnapin;

$groupObject = get-monitoringobject | where {$_.DisplayName -eq $group};
$groupagents = $groupObject.getrelatedmonitoringobjects()

foreach ($agent in $groupAgents)

{

$computerPrincipalName = $agent.displayname
$computerPrincipalName

$computerClass = get-monitoringclass -name:Microsoft.Windows.Computer
$healthServiceClass = get-monitoringclass -name:Microsoft.SystemCenter.HealthService
$healthServiceWatcherClass = get-monitoringclass -name:Microsoft.SystemCenter.HealthServiceWatcher

$computerCriteria = "PrincipalName='" + $computerPrincipalName + "'"
$computer = get-monitoringobject -monitoringclass:$computerClass | Where{$_.Displayname -like $computerPrincipalName}
$startTime = [System.DateTime]::Now
$endTime = $startTime.AddHours($numberOfHoursInMaintenanceMode)

"Putting " + $computerPrincipalName + " into maintenance mode"
New-MaintenanceWindow -startTime:$startTime -endTime:$endTime -monitoringObject:$computer -comment:$comment

}