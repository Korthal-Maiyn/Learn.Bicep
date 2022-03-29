@description('The Azure region into which the resources should be deployed.')
param location string

@description('The type of environment. This must be dev or prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string

@description('The name of the Cosmos DB account. This name must be globally unique.')
param cosmosDBAccountName string

var cosmosDBDatabaseName = 'ServiceCatalog'
var cosmosDBDatabaseThroughput = (environmentType == 'prod') ? 1000 : 400
var cosmosDBContainerName = 'Services'
var cosmosDBContainerPartitionKey = '/serviceid'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-11-15-preview' = {
  parent: cosmosDBAccount
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {}
    }
  }
}
