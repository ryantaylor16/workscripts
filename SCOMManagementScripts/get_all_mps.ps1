$all_mps = get-managementpack
foreach($mp in $all_mps)
{
export-managementpack -managementpack $mp -path "C:\SCOM_Prod_MP_Backups"
} 
