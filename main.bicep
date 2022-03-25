@description('The Azure region into which the resources should be deployed.')
param location string = 'australiaeast'

@description('The name of the App Service app.')
param AppServiceAppName string = 'kor-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'korthcore-plan'

module app 'modules/app.bicep' = {
  name: 'korthcore-app'
  params: {
    AppServiceAppName: AppServiceAppName
    AppServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

@description('The host name to use to access the website.')
output websiteHostName string = app.outputs.appServiceAppHostName
