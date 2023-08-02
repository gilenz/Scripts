#Create Vnet
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName az104-08-rg01-CRFZ5XJIOM `
  -Location EastUS `
  -Name P2SVnet `
  -AddressPrefix 192.168.0.0/24


  #Create VPN Subnet
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name GatewaySubnet `
  -AddressPrefix 192.168.0.0/27 `
  -VirtualNetwork $vnet
 
#Build vNET
  $vnet | Set-AzVirtualNetwork




  #VPN Gateway Public IP address
$VPNGatewayIP= New-AzPublicIpAddress `
    -Name p2spublicip-pip `
    -ResourceGroupName az104-08-rg01-CRFZ5XJIOM `
    -Location 'East US' `
    -AllocationMethod Static
 
#VPN Gateway Configuration
$vnet = Get-AzVirtualNetwork `
    -Name P2SVnet `
    -ResourceGroupName az104-08-rg01-CRFZ5XJIOM
 
$vpnsubnet = Get-AzVirtualNetworkSubnetConfig `
    -Name 'GatewaySubnet' `
    -VirtualNetwork $vnet
 
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
    -Name gwipconfig1 `
    -SubnetId $vpnsubnet.Id `
    -PublicIpAddressId $VPNGatewayIP.Id
 
#Create VPN Gateway
New-AzVirtualNetworkGateway `
    -Name p2svpngw `
    -ResourceGroupName az104-08-rg01-CRFZ5XJIOM `
    -Location 'East US' `
    -IpConfigurations $gwipconfig `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -GatewaySku VpnGw1








    #Create Certs - Root 
$rootcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=rootcert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign 
 
 
#Create Certs - Client
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $rootcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")


#Extract Root Cert
$certfind = Get-ChildItem -Path Cert:\CurrentUser\My | ?{$_.Subject -eq 'CN=rootcert'}

export-Certificate  -cert $certfind -FilePath C:\Users\Administrator\Desktop\exportcert.cer -type CERT  -NoClobber
certutil -encode C:\Users\Administrator\Desktop\exportcert.cer C:\Users\Administrator\Desktop\useme.cer


$Gateway = Get-AzVirtualNetworkGateway -ResourceGroupName az104-08-rg01-CRFZ5XJIOM -Name p2svpngw
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -VpnClientAddressPool 201.169.0.0/16





#Upload configuration changes to Azure VPN Gateway
$P2SRootCertName = "P2SRootCert.cer"
$filePathForCert = "C:\Users\Administrator\Desktop\useme.cer"
$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
$CertBase64 = [system.convert]::ToBase64String($cert.RawData)
$p2srootcert = New-AzVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64
Add-AzVpnClientRootCertificate -VpnClientRootCertificateName $P2SRootCertName -VirtualNetworkGatewayname "p2svpngw" -ResourceGroupName "az104-08-rg01-CRFZ5XJIOM" -PublicCertData $CertBase64


$profile=New-AzVpnClientConfiguration -ResourceGroupName "az104-08-rg01-CRFZ5XJIOM" -Name "p2svpngw" -AuthenticationMethod "EapTls"

$URL = $profile.VPNProfileSASUrl
Start-Process $URL