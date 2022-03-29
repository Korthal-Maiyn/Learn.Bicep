@description('The Azure region in which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be dev or prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string
