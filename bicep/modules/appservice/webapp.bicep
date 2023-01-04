param location string
param suffix string
param fqdnStorage string

var linuxFxVersion = 'TOMCAT|9.0-java11'

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'plan-${suffix}'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
    tier: 'Standard'    
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2018-11-01' = {
  name: 'webapp-${suffix}'
  location: location  
  properties: {
    serverFarmId: serverFarm.id        
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true      
      appSettings: [
        {
          name: 'FQDN'
          value: fqdnStorage
        }
        {
          name: 'Location'
          value: '/pictures/'
        }
      ]
    }    
    clientAffinityEnabled: false
    httpsOnly: true          
  }  
}

output webAppname string = webApp.name
