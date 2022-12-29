param subnetId string
param location string
param storageId string
param vnetName string
param vnetId string

var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
// var privateFileShareDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
// var privateQueueShareDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
// var privateTableShareDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'

resource storageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
}

// resource storageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateFileShareDnsZoneName
//   location: 'global'
// }

// resource storageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateQueueShareDnsZoneName
//   location: 'global'
// }

// resource storageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateTableShareDnsZoneName
//   location: 'global'
// }

resource privateEndpointBlob 'Microsoft.Network/privateEndpoints@2021-05-01' = {
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

// resource privateEndpointQueue 'Microsoft.Network/privateEndpoints@2021-05-01' = {
//   name: 'pe-queue'
//   location: location
//   properties: {
//     subnet: {
//       id: subnetId
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'pe-queue'
//         properties: {
//           privateLinkServiceId: storageId
//           groupIds: [
//             'queue'
//           ]
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointTable 'Microsoft.Network/privateEndpoints@2021-05-01' = {
//   name: 'pe-table'
//   location: location
//   properties: {
//     subnet: {
//       id: subnetId
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'pe-table'
//         properties: {
//           privateLinkServiceId: storageId
//           groupIds: [
//             'table'
//           ]
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointFile 'Microsoft.Network/privateEndpoints@2021-05-01' = {
//   name: 'pe-file'
//   location: location
//   properties: {
//     subnet: {
//       id: subnetId
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'pe-file'
//         properties: {
//           privateLinkServiceId: storageId
//           groupIds: [
//             'file'
//           ]
//         }
//       }
//     ]
//   }
// }

resource networkLinkStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageBlobDnsZone.name}/${vnetName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// resource networkLinkFile 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   name: '${storageFileDnsZone.name}/${vnetName}'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: vnetId
//     }
//     registrationEnabled: false
//   }
// }

// resource networkLinkQueue 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   name: '${storageQueueDnsZone.name}/${vnetName}'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: vnetId
//     }
//     registrationEnabled: false
//   }
// }

// resource networkLinkTable 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   name: '${storageTableDnsZone.name}/${vnetName}'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: vnetId
//     }
//     registrationEnabled: false
//   }
// }

// resource dnsZoneGroupFile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
//   name: '${privateEndpointFile.name}/default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: storageFileDnsZone.name
//         properties: {
//           privateDnsZoneId: storageFileDnsZone.id
//         }
//       }         
//     ]
//   }
// }


resource dnsZoneGroupBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointBlob.name}/default'
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


// resource dnsZoneGroupQueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
//   name: '${privateEndpointQueue.name}/default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: storageQueueDnsZone.name
//         properties: {
//           privateDnsZoneId: storageQueueDnsZone.id
//         }
//       }         
//     ]
//   }
// }

// resource dnsZoneGroupTable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
//   name: '${privateEndpointTable.name}/default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: storageTableDnsZone.name
//         properties: {
//           privateDnsZoneId: storageTableDnsZone.id
//         }
//       }         
//     ]
//   }
// }

