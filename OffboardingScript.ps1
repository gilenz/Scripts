$domain = "enter your domain" ## enter your domain###
$user = Read-Host "enter username"
$UPN = "$user@$domain"
Import-Module ActiveDirectory
Disable-ADAccount -Identity $user ### disable user in AD   ###
### install MSOnline Module #####
$folder = 'C:\Program Files\WindowsPowerShell\Modules\MSOnline' 
if ( Test-Path -Path $folder )                                  
 {
echo " MSOnline module installed"
}
else {
echo "MSOnline module not installed now installing"
Install-Module msonline -Force
}
Connect-MsolService
$CheckLicense = Get-MsolUser -UserPrincipalName "$UPN" | Select-Object -Property islicense 

if ($CheckLicense)  #######check if user has license######
{
$MsolUser = Get-MsolUser -UserPrincipalName $UPN
$AssignedLicenses = $MsolUser.licenses.AccountSkuId
foreach($License in $AssignedLicenses) {
    Set-MsolUserLicense -UserPrincipalName "$UPN" -RemoveLicenses $License
}
 
 
 ### install ExchangeOnlineManagement Module #####
$folder = 'C:\Program Files\WindowsPowerShell\Modules\ExchangeOnlineManagement' 
if ( Test-Path -Path $folder )                      
 {
echo " ExchangeOnlineManagement module installed"
}
else {
echo "ExchangeOnlineManagement module not installed now installing"
Install-Module ExchangeOnlineManagement -Force
}
Connect-ExchangeOnline
Set-Mailbox -Identity $UPN -Type shared            ##### convert to shared mailbox#####


}



else                                                       
{
 ### install ExchangeOnlineManagement Module #####
$folder = 'C:\Program Files\WindowsPowerShell\Modules\ExchangeOnlineManagement' 
if ( Test-Path -Path $folder )                      
 {
echo " ExchangeOnlineManagement module installed"
}
else {
echo "ExchangeOnlineManagement module not installed now installing"
Install-Module ExchangeOnlineManagement -Force
}
Connect-ExchangeOnline
Set-Mailbox -Identity $UPN -Type shared 
}


