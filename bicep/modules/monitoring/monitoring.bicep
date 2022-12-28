param location string
param suffix string


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: 'log-${suffix}'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource insight 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${suffix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output insightName string = insight.name
