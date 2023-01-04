param location string
param suffix string

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'plan-${suffix}'
  location: location
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
      appSettings: [
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }    
      ]
      linuxFxVersion: 'TOMCAT|9.0-java11'
      alwaysOn: true      
    }    
    clientAffinityEnabled: false
    httpsOnly: true          
  }  
}

output webAppname string = webApp.name
