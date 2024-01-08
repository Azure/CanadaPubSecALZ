param hubName string

resource vHUB 'Microsoft.Network/virtualHubs@2023-05-01' existing = {
  name: hubName
}

//Define default Routes
resource noneRouteTable 'Microsoft.Network/virtualHubs/routeTables@2023-05-01' existing = {
  name: 'None'
  parent: vHUB
}
resource defaultRouteTable 'Microsoft.Network/virtualHubs/routeTables@2023-05-01' existing = {
  name: 'defaultRouteTable'
  parent: vHUB
}

output noneRouteTableResourceId string = noneRouteTable.id
output defaultRouteTableResourceId string = defaultRouteTable.id
