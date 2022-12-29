targetScope = 'subscription'

param location string
param subnetId string
param storageName string
param resourceGroupName string
param customDomainStorageFQDN string

@secure()
param certificate_data string

@secure()
param certificate_password string

var suffix = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

var appgwName = 'agw-${suffix}'
var appGwId = resourceId('Microsoft.Network/applicationGateways',appgwName)

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'pip-gw-${suffix}'
  location: location
  sku: {
      name: 'Standard'
  }
  properties: {
      publicIPAddressVersion: 'IPv4'
      publicIPAllocationMethod: 'Static'
      idleTimeoutInMinutes: 4
  }
}

resource appgw 'Microsoft.Network/ApplicationGateways@2020-06-01' = {
  name: appgwName
  location: location
  properties: {
      sku: {
          name: 'WAF_v2'
          tier: 'WAF_v2'         
      }
      autoscaleConfiguration: {
        minCapacity: 1
        maxCapacity: 10
      }
      gatewayIPConfigurations: [
          {
              name: 'appGatewayConfig'
              properties: {
                  subnet: {
                      id: subnetId
                  }
              }
          }
      ]
      sslCertificates: [
          {
              name: 'wild'
              properties: {
                  data: certificate_data
                  password: certificate_password
              }
          }
      ]
      trustedRootCertificates: []
      frontendIPConfigurations: [
          {
              name: 'appGwPublicFrontendIp'
              properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  publicIPAddress: {
                      id: pip.id
                  }
              }
          }
      ]
      frontendPorts: [
          {
              name: 'port_443'
              properties: {
                  port: 443
              }
          }
      ]
      backendAddressPools: [
          {
              name: 'storagePool'
              properties: {
                  backendAddresses: [
                      {
                          fqdn: '${storageName}.blob.${environment().suffixes.storage}'
                      }
                  ]
              }
          }           
      ]
      backendHttpSettingsCollection: [
          {
              name: 'https-settings-storage'
              properties: {
                  port: 443
                  protocol: 'Https'
                  cookieBasedAffinity: 'Disabled'
                  pickHostNameFromBackendAddress: false
                  path: '/'
                  hostName: '${storageName}.blob.${environment().suffixes.storage}'
                  requestTimeout: 20
                  probe: {                                                
                      id: '${appGwId}/probes/storageProbe'
                  }
              }
          }                                   
      ]
      httpListeners: [
          {
              name: 'https-listener-storage'
              properties: {
                  frontendIPConfiguration: {
                      id: '${appGwId}/frontendIPConfigurations/appGwPublicFrontendIp'
                  }
                  frontendPort: {
                      id: '${appGwId}/frontendPorts/port_443'
                  }
                  sslCertificate: {
                      id: '${appGwId}/sslCertificates/wild'
                  }
                  hostName: customDomainStorageFQDN
                  hostNames: [
                    customDomainStorageFQDN
                  ]
                  protocol: 'Https'
                  requireServerNameIndication: true
              }
          }                            
      ]
      requestRoutingRules: [
          {
              name: 'https-rule-storage'
              properties: {
                  ruleType: 'Basic'
                  priority: 100
                  httpListener: {
                      id: '${appGwId}/httpListeners/https-listener-storage'
                  }
                  backendAddressPool: {
                      id: '${appGwId}/backendAddressPools/storagePool'
                  }
                  backendHttpSettings: {
                      id: '${appGwId}/backendHttpSettingsCollection/https-settings-storage'
                  }
              }
          }                                        
      ]
      probes: [
          {
              name: 'storageProbe'
              properties: {
                  protocol: 'Https'                    
                  path: '/'
                  interval: 30
                  timeout: 30
                  unhealthyThreshold: 3
                  pickHostNameFromBackendHttpSettings: true
                  minServers: 0
                  match: {
                    statusCodes: [
                      '400'
                    ]
                  }
              }
          }                         
      ]
      enableHttp2: false
      webApplicationFirewallConfiguration: {
          enabled: true
          firewallMode: 'Prevention'
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          requestBodyCheck: true
          maxRequestBodySizeInKb: 128
          fileUploadLimitInMb: 100
          disabledRuleGroups: [
              {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [                        
                      942200
                      942100
                      942110
                      942180
                      942260
                      942340
                      942370
                      942430
                      942440                        
                  ]
              }
              {
                  ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
                  rules: [                        
                      920300
                      920330                     
                  ]
              }   
              {
                  ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
                  rules: [                        
                      931130                                             
                  ]
              }                                    
          ]
      }        
  }
}
