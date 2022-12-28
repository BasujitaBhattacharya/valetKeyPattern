param location string
param suffix string

resource strApp 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'str${suffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${strApp.name}/default/pictures'
}

output storageAccountName string = strApp.name
