# Create variables to store the location and resource group names.
$location = "eastus"
$ResourceGroupName = "az104-08-rg01-XK0C9BRYSM"
# Create variables to store the storage account name and the storage account SKU information
$StorageAccountName = "maaxpaynestorageaccount"
$SkuName = "Standard_LRS"

# Create a new storage account
$StorageAccount = New-AzStorageAccount `
  -Location $location `
  -ResourceGroupName $ResourceGroupName `
  -Type $SkuName `
  -Name $StorageAccountName

Set-AzCurrentStorageAccount `
  -StorageAccountName $storageAccountName `
  -ResourceGroupName $resourceGroupName



  # Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name mySubnet `
  -AddressPrefix 10.0.0.0/26

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name MyVnet `
  -AddressPrefix 10.0.0.0/24 `
  -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "OraganizationDNS"



  # Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
  -Name myNetworkSecurityGroupRuleRDP `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389 `
  -Access Allow




  # Create a network security group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name myNetworkSecurityGroup `
  -SecurityRules $nsgRuleRDP


  # Create a virtual network card and associate it with public IP address and NSG
$nic = New-AzNetworkInterface `
  -Name myNic `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id


  # Define a credential object to store the username and password for the VM
$Credential = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create the VM configuration object
$VmName = "DC002"
$VmSize = "Standard_DS1_v2"
$VirtualMachine = New-AzVMConfig `
  -VMName $VmName `
  -VMSize $VmSize

$VirtualMachine = Set-AzVMOperatingSystem `
  -VM $VirtualMachine `
  -Windows `
  -ComputerName "DC002" `
  -Credential $Credential -ProvisionVMAgent

$VirtualMachine = Set-AzVMSourceImage `
  -VM $VirtualMachine `
  -PublisherName "MicrosoftWindowsServer" `
  -Offer "WindowsServer" `
  -Skus "2019-Datacenter" `
  -Version "latest"

# Sets the operating system disk properties on a VM.
$VirtualMachine = Set-AzVMOSDisk `
  -VM $VirtualMachine `
  -CreateOption FromImage | `
  Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName `
  -StorageAccountName $StorageAccountName -Enable |`
  Add-AzVMNetworkInterface -Id $nic.Id


# Create the VM.
New-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VM $VirtualMachine

  Get-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName | Select IpAddress