param acrName string
param servicePlanName string
param webAppName string
param location string
param containerImageName string
param containerImageTag string
param acrAdminUsername string
param acrAdminPassword string



resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  properties: {
    adminUserEnabled: true
  }
  sku: {
    name: 'Basic'
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: servicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: servicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acr.loginServer}/${containerImageName}:${containerImageTag}'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        },
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: acr.properties.loginServer
        },
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrAdminUsername
        },
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrAdminPassword
        }
      ]
    }
  }
}
