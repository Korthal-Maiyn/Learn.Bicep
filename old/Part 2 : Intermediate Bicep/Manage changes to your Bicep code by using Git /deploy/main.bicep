@description('The Azure region in which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be dev or prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string

@description('The name of the App Service app. This name must be globally unique.')
param appServiceAppName string = 'korweb-${uniqueString(resourceGroup().id)}'

@description('The name of the Cosmos DB account. This name must be globally unique.')
param cosmosDBAccountName string = 'korweb-${uniqueString(resourceGroup().id)}'

module appService 'modules/app-service.bicep' = {
  name: 'app-service'
  params: {
    appServiceAppName: appServiceAppName
    environmentType: environmentType
    location: location
  }
}

module cosmosDB 'modules/cosmos-db.bicep' = {
  name: 'cosmos-db'
  params: {
    cosmosDBAccountName: cosmosDBAccountName
    environmentType: environmentType
    location: location
  }
}
