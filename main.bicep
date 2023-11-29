param location string
param acrName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param acrUsername string
@secure()
param acrPassword string

// Azure Container Registry
module acr 'modules/container-registry/registry/main.bicep' = {
  name: '${acrName}-deploy'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
}

// Azure Service Plan for Linux
module appServicePlan 'modules/web/serverfarm/main.bicep' = {
  name: '${appServicePlanName}-deploy'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

// Azure Web App for Linux containers
// Azure Web App for Linux containers
module webApp 'modules/web/site/main.bicep' = {
  name: '${webAppName}-deploy'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      DOCKER_REGISTRY_SERVER_URL: '${acrName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: acrUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: acrPassword
    }
  }
}
