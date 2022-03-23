param location string
param appServiceAppName string

@allowed([
  'dev'
  'prod'
])
param environmentType string

var appServicePlanName = 'korthcore-plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_V3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
