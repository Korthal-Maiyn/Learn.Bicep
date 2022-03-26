@description('The host name (address) of the origin server.')
param originHostName string

@description('The name of the CDN profile.')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('The name of the CDN endpoint.')
param endpointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Indicates whether the CDN endpoint requires HTTPs connections.')
param httpsOnly bool

var originName = 'kor-igin'

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  parent: cdnProfile
  name: endpointName
  location: 'global'
  properties: {
    originHostHeader: originHostName
    isHttpAllowed: !httpsOnly
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'application/x-javascript'
      'text/css'
      'text/html'
      'text/javascript'
      'text/plain'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: originName
        properties: {
          hostName: originHostName
        }
      }
    ]
  }
}

@description('The host name of the CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
