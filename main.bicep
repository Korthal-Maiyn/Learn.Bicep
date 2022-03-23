resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: 'korthcorestorage'
  location: 'australiaeast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'korthcore-starter'
  location: 'australiaeast'
  sku: {
    name: 'F1'
  }
}

resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'korthcore-1'
  location: 'australiaeast'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
