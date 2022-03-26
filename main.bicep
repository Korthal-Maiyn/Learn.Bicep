@description('The Azure region into which the resources should be deployed.')
param location string = 'australiaeast'

@description('The name of the App Service app.')
param AppServiceAppName string = 'kor-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed')
param deployCdn bool = true

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

module cdn 'modules/cdn.bicep' = if (deployCdn){
  name: 'korthcore-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

@description('The host name to use to access the website.')
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
