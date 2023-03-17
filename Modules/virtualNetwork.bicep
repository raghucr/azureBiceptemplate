param ResourcePrefix string = ''
param ResourceName string = ''
param location string = resourceGroup().location
param virtualNetworkPrefix string
param subnetPrefix string
param nsgId string
param tagValues object
param publicIp string 

param subnetName string= 'Subnet'

var vnetName = !(empty(ResourcePrefix)) ? '${ResourcePrefix}-VNET' : ResourceName

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  tags:tagValues
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
    ]
  }
}

output vnetid string = vnet.id
output vnetname string = vnet.name

var vnicName = !(empty(ResourcePrefix)) ? '${ResourcePrefix}-nic' : ResourceName

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: vnicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [

    vnet
  ]
}

output nicid string = nic.id

