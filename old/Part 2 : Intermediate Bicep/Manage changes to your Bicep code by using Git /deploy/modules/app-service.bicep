@description('The Azure region into which the resources should be deployed.')
param location string

@description('The type of environment. This must be dev or prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string

@description('The name of the App Service app. This name must be globally unique.')
param appServiceAppName string

var appServicePlanName = 'korthcore-website-plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'
var appServicePlanTierName = (environmentType == 'prod') ? 'PremiumV3' : 'Free'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanTierName
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
