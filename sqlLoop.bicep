﻿@description('The Azure regions into which the resources should be deployed.')
param locations array = [
  'australiaeast'
  'eastus2'
  'eastasia'
]

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

module databases 'modules/sqlServer.bicep' = [for location in locations: {
  name: 'kordb-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]
