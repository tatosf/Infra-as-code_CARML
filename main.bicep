param location string
param acrName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string
@secure()
param keyVaultName string 
param kevVaultSecretNameACRUsername string = 'acr-username'
param kevVaultSecretNameACRPassword1 string = 'acr-password1'
param kevVaultSecretNameACRPassword2 string = 'acr-password2'

// Reference to existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}


// Azure Container Registry
module acr 'modules/container-registry/registry/main.bicep' = {
  name: '${acrName}-deploy'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    adminCredentialsKeyVaultSecretUserName: kevVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: kevVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: kevVaultSecretNameACRPassword2
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
module webApp 'modules/web/site/main.bicep' = {
  dependsOn: [
    appServicePlan
    acr
    keyVault
  ]
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
      DOCKER_REGISTRY_SERVER_USERNAME: kevVaultSecretNameACRUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: kevVaultSecretNameACRPassword1
    }
  }
}
