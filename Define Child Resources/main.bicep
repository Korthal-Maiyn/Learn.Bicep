@description('The name of the Cosmos DB Account.')
param cosmosDBAccountName string = 'kornd-${uniqueString(resourceGroup().id)}'

@description('The Cosmos DB throughput value.')
param cosmosDBDatabaseThroughput int = 400

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

var cosmosDBDatabaseName = 'KorthTests'
var cosmosDBContainerName = 'KorthTests'
var cosmosDBContainerPartitionKey = '/coreId'

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
