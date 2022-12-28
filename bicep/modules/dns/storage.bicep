param subnetId string
param location string
param storageId string
param vnetName string
param vnetId string

var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource storageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-blob'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-blob'
        properties: {
          privateLinkServiceId: storageId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource networkLinkSpokeDB 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageBlobDnsZone.name}/${vnetName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: true
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: storageBlobDnsZone.name
        properties: {
          privateDnsZoneId: storageBlobDnsZone.id
        }
      }         
    ]
  }
}
