resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'korvnet001'
  location: resourceGroup().location
  tags: {
    'CostCenter': '90210'
    'Owner': 'Korthcore'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: 'korsub001'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'korsub002'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
