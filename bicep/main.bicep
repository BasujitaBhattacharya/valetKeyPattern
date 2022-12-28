targetScope = 'subscription'

@description('The location of the Azure resources')
param location string

@description('The name of the resource group')
param rgName string

var suffix = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vnet 'modules/network/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnet'
  params: {
    location: location 
    suffix: suffix
  }
}

module monitoring 'modules/monitoring/monitoring.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'monitoring'
  params: {
    location: location
    suffix: suffix
  }
}

module storage 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'storage'
  params: {
    location: location
    suffix: suffix
  }
}

module function 'modules/function/function.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'function'
  params: {
    appInsightName: monitoring.outputs.insightName
    location: location
    storageName: storage.outputs.storageAccountName
    suffix: suffix
    subnetId: vnet.outputs.subnetDelegationId
  }
}

module dnsStorage 'modules/dns/storage.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'dns'
  params: {
    location: location
    storageId: storage.outputs.storageId
    subnetId: vnet.outputs.subnetPeId
    vnetId: vnet.outputs.vnetId
    vnetName: vnet.outputs.vnetName
  }
}

output functionName string = function.outputs.functionName
output storageName string = storage.outputs.storageAccountName
