Set-ExecutionPolicy Unrestricted -Force
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /f /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6'
$adapters=( gwmi win32_networkadapterconfiguration )
Foreach ($adapter in $adapters){
  Write-Host $adapter
  $adapter.settcpipnetbios(2)
}
Set-WinSystemLocale he-IL
$sys = Get-WmiObject Win32_Computersystem –EnableAllPrivileges
$sys.AutomaticManagedPagefile = $false
$sys.put()
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name='c:\\pagefile.sys'"
$pagefile.Delete()
Rename-LocalUser -Name administrator -NewName TadAdmin
$localuser = "TadAdmin"
$password = Read-Host "enter TadAdmin password " -AsSecureString
Set-LocalUser -Name $localuser -Password $password -Verbose
Enable-LocalUser -Name TadAdmin -Confirm
$user = Read-Host "enter your username"
$pcname  = Read-Host "enter computer name"
$key = powershell "(Get-WmiObject -query ‘select * from SoftwareLicensingService’).OA3xOriginalProductKey"
slmgr /ipk $key
Set-Volume -DriveLetter C -NewFileSystemLabel "$pcname"
$domain = "tadiran-batt.com"
Add-Computer -DomainName $domain -credential tadiran-batt.com\$user -ComputerName $env:computername -newname $pcname -restart


