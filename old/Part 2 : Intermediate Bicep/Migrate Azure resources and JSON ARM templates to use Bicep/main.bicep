@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the size of the virtual machine to deploy.')
param virtualMachineSizeName string = 'Standard_D2s_v3'

@description('The name of the storage account SKU to use for the virtual machine\'s managed disk.')
param virtualMachineManagedDiskStorageAccountType string = 'Premium_LRS'

@description('The administrator username for the virtual machine.')
param virtualMachineAdminUsername string = 'korthal'

@description('The administrator password for the virtual machine.')
@secure()
param virtualMachineAdminPassword string

@description('The name of the SKU of the public IP address to deploy.')
param publicIPAddressSkuName string = 'Basic'

@description('The virtual network address range.')
param virtualNetworkAddressPrefix string

@description('The default subnet address range within the virtual network.')
param virtualNetworkDefaultSubnetAddressPrefix string

var virtualNetworkName = 'Korthcore-vnet'
var virtualMachineName = 'KorthcoreServer'
var networkInterfaceName = 'korthcoreserver890'
var publicIPAddressName = 'KorthcoreServer-ip'
var networkSecurityGroupName = 'KorthcoreServer-nsg'
var virtualNetworkDefaultSubnetName = 'default'
var virtualMachineImageReference = {
  publisher: 'canonical'
  offer: '0001-com-ubuntu-server-focal'
  sku: '20_04-lts'
  version: 'latest'
}
var virtualMachineOSDiskName = 'KorthcoreServer-sda'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: networkSecurityGroupName
  location: location
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: publicIPAddressSkuName
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: virtualNetworkDefaultSubnetName
        properties: {
          addressPrefix: virtualNetworkDefaultSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
  }

  resource defaultSubnet 'subnets' existing = {
    name: virtualNetworkDefaultSubnetName 
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSizeName
    }
    storageProfile: {
      imageReference: virtualMachineImageReference
      osDisk: {
        osType: 'Linux'
        name: virtualMachineOSDiskName
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: virtualMachineManagedDiskStorageAccountType
        }
        diskSizeGB: 30
      }
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: virtualMachineAdminUsername
      adminPassword: virtualMachineAdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: virtualNetwork::defaultSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}
