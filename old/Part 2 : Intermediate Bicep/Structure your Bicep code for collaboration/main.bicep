@description('The region in which the Azure resource is to be deployed.')
param location string = resourceGroup().location

@description('Which environment type is to be set. Allowed values are dev and prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string

@description('A prefix to add to resource names that need to be globally unique. Maximum length of 13.')
@maxLength(13)
param resourceNamePrefix string = uniqueString(resourceGroup().id)

@description('The administrator login username for the SQL Server')
param sqlServerAdministratorLogin string

@description('The administrator login password for the SQL Server.')
@secure()
param sqlServerAdministratorLoginPassword string

@description('Default set of Tags to apply to each resource.')
param tags object = {
  CostCentre: 'Korthcore'
  DataClassification: 'Public'
  Owner: 'Korthal Maiyn'
  Environment: 'Production'
}

// Define the names for resources
var appServiceAppName = '${resourceNamePrefix}web'
var appServicePlanName = 'appServicePlan'
var sqlServerName = '${resourceNamePrefix}sql'
var sqlDatabaseName = 'Korthcore.Web'
var managedIdentityName = 'Web'
var applicationInsightsName = 'Korthcore.AppInsights'
var storageAccountName = '${resourceNamePrefix}storWeb'
var blobContainerNames = [
  'productSpecs'
  'productManuals'
]

@description('Define the SKUs for each component based on the environment type.')
var environmentConfigurationMap = {
  dev: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'S1'
        tier: 'Standard'
      }
    }
  }
}

@description('The role definition ID of the build-in Azure \'Contributor\' role.')
var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'

@description('The SQL Server Resource to be deployed.')
resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    version: '12.0'
  }
}

@description('The SQL Database to be created. Requires sqlServer resource.')
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: environmentConfigurationMap[environmentType].sqlDatabase.sku
  tags: tags
}

@description('Configures the SQL Server Firewall Rules to allow all Azure IPs. Requires sqlServer resource.')
resource sqlFirewallRuleAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  tags: tags
}

resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: storageAccountConnectionString
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {} // This format is required when working with user-assigned managed identities.
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'

    resource containers 'containers' = [for blobContainerName in blobContainerNames: {
      name: blobContainerName
    }]
  }
}

@description('A user-assigned managed identity that is used by the App Service app to communicate with a storage account.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
  tags: tags
}

@description('Grant the \'Contributor\' role to the user-assigned managed identity, at the scope of the resource group.')
resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(contributorRoleDefinitionId, resourceGroup().id) // Create a GUID based on the role definition ID and scope (resource group ID). This will return the same GUID every time the template is deployed to the same resource group.
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: managedIdentity.properties.principalId
    description: 'Grant the "Contributor" role to the user-assigned managed identity so it can access the storage account.'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
  }
}
