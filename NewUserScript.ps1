$firstname = Read-Host "enter first name"
$lastname = Read-Host "enter last name"
$domain = "your domain"          ##### need to enter you domain here###
$final = $lastname.substring(0,1)
$username = "$firstname-$final"
$UPN = "$username@$domain"
$equal =  Get-ADUser -Identity $username


######### check if username exist #####
if ( $equal.samaccountname -eq $username )   
{
$final = $lastname.Substring(0,2)
$username = "$firstname-$final"
$UPN = "$username@$domain"
}

New-ADUser -Enabled $true -ChangePasswordAtLogon $true -Path "OU=  ,OU=  ,OU=  ,DC= ,DC=  " -name "$firstname $lastname" -UserPrincipalName "$UPN" -SamAccountName "$username" -GivenName "$firstname" -Surname "$lastname" -AccountPassword(Read-Host -AsSecureString "Input user first password") -EmailAddress "$UPN" -DisplayName "$firstname $lastname" ## enter the path for the user###
$Server = "enter ad connect server" ## enter you ad connect server##
$UserCredential = Get-Credential
$session = New-PSSession -ComputerName $Server -Credential $UserCredential
Invoke-Command $session -Scriptblock { Start-ADSyncSyncCycle -PolicyType Delta }
Remove-PSSession -ComputerName $Server
Start-Sleep -Seconds 50

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
$License = Get-MsolAccountSku | Where-Object -Property accountskuid -EQ reseller-account:O365_BUSINESS_PREMIUM | Select-Object -Property accountskuid -ExpandProperty accountskuid
$user = Get-MsolUser -All -UnlicensedUsersOnly | Where-Object displayname -EQ "$firstname $lastname"
$user | Set-MsolUser -UsageLocation IL
$user | Set-MsolUserLicense -AddLicenses $License
$mf= New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$mf.RelyingParty = "*"
$mfa = @($mf)
Set-MsolUser -UserPrincipalName "$UPN" -StrongAuthenticationRequirements $mfa



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
Add-DistributionGroupMember -Identity "Distribution List" -Member "$UPN" ## add user to distribution list###

