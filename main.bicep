param resourcePrefix string
param virtualNetworkPrefix string
param currentDate string = utcNow('yyyy-MM-dd')
param publicIpSku string
param publicIPAllocationMethod string
param vmName string
param publicIpName string

param OSVersion string
      
param vmSize string
param securityType string

param adminUsername string
@secure()
param adminPassword string


var subnetname = '${resourcePrefix}-sn'
var tagValues = {
  CreatedBy: 'BICEPDeployment'
  deploymentDate: currentDate
}
module publicIp 'Modules/publicIp.bicep' = {
  name: 'publicIp'
  params: {
    vmName: vmName
    publicIpName: publicIpName
    tagValues: tagValues
    publicIpSku: publicIpSku
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

module sta 'Modules/storageAccount.bicep' = {
  name: 'sta'
  params: {
    storageAccountPrefix: resourcePrefix
    tagValues: tagValues
  }
}

module nsg 'Modules/networkSecurityGroup.bicep' = {
  name: 'nsg'
  params: {
    ResourcePrefix: resourcePrefix
    tagValues: tagValues
    securityRules: [
      {
        name: 'default-allow-3389'
  
      priority: 1000
      access: 'Allow'
      direction: 'Inbound'
      destinationPortRange: '3389'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      }
    ]
  }
}

module vnet 'Modules/virtualNetwork.bicep' = {
  name: 'vnet'
  params: {
    ResourcePrefix: resourcePrefix
    tagValues: tagValues
    subnetName: subnetname
    virtualNetworkPrefix: '10.0.0.0/16'
    subnetPrefix:'10.0.0.0/24'
    nsgId: nsg.outputs.nsgid
    publicIp:publicIp.outputs.publicipid
  }
}

module vm 'Modules/virtualmachine.bicep'={
  name:'vm'
  params:{
       
     OSVersion:OSVersion
     adminUsername:adminUsername
     adminPassword:adminPassword
     vmSize:vmSize
     vmName :vmName
     securityType:securityType
     nicid:vnet.outputs.nicid
     stauri:sta.outputs.stauri
  }
}



