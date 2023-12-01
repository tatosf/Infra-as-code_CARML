param keyVaultName string
param location string = resourceGroup().location

module keyvault 'modules/key-vault/vault/main.bicep' = {
  name: '${uniqueString(deployment().name)}-kv'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
