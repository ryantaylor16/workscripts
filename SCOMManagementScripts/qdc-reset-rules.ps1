$rootMS="OPRDOASAS303.corp.intuit.net"
add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client" -ErrorVariable errSnapin;
set-location "OperationsManagerMonitoring::" -ErrorVariable errSnapin;
new-managementGroupConnection -ConnectionString:$rootMS -ErrorVariable errSnapin;
set-location $rootMS -ErrorVariable errSnapin;

get-alert -criteria 'ResolutionState = ''0'' AND IsMonitorAlert = ''False'''| resolve-alert -comment "CLOSE ALL Alerts created by Rules" | out-null
get-alert -criteria 'ResolutionState = ''5'' AND IsMonitorAlert = ''False'''| resolve-alert -comment "CLOSE ALL Alerts created by Rules" | out-null