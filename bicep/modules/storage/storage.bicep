param location string
param suffix string

var functionContentShareName = 'function-content-share'

resource strApp 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'str${suffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'    
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'      
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${strApp.name}/default/pictures'
}

resource functionContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${strApp.name}/default/${functionContentShareName}'
}

output storageAccountName string = strApp.name
output storageId string = strApp.id
output functionShareName string = functionContentShare.name
