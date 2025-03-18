resource "azurerm_resource_group" "default" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "adme" {
  name                = var.adme_vnet_name
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "adme" {
    name                 = var.adme_vnet_subnet_name
    resource_group_name  = azurerm_resource_group.default.name
    virtual_network_name = azurerm_virtual_network.adme.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "random_id" "private_link_service_connection_id" {
  byte_length = 16
}

resource "azurerm_resource_group_template_deployment" "default" {
  name                = var.adme_name
  resource_group_name = azurerm_resource_group.default.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
      value = "${var.adme_name}"}
    "location" = {
      value = "${var.location}"}
    "tagsByResource" = {
      value = {}
    }
    "authAppId" = {
      value ="${var.authAppId}"
    }
    "dataPartitionNames" = {
      value = [
        {
        "name"="${var.adme_datapartition_name1}"
        }
      ]
    }
    "cmkEnabled" = {
      value =false}
    "encryption" =  {
      value ={}}
    "identity" = {
      value ={}}
    "corsRules" = {
      value =[]}
    "sku" = {
      value ={
      "name" = "${var.adme_sku}"
      }
    }
    "publicNetworkAccess" = {
      value =false}
    "privateEndpoints" = {
      value =[{
        "subscription": {
          "authorizationSource": "RoleBased",
          "displayName": "${var.subscription_display_name}",
          "state": "Enabled",
          "subscriptionId": "${var.subscription_id}",
          "subscriptionPolicies": {},
          "tenantId": "${var.tenant_id}",
          "promotions": [],
          "uniqueDisplayName": "${var.subscription_display_name}"
        },
        "location": {
          "id": "/subscriptions/${var.subscription_id}/locations/${var.location}",
          "name": "${var.location}",
          "metadata": {}
        },
        "resourceGroup": {
          "mode": 0,
          "value": {
            "name": "${var.rg_name}",
            "location": "${var.location}",
            "provisioningState": "Succeeded"
          }
        },
        "privateEndpoint": {
          "id": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Network/privateEndpoints/${var.Private_Endpoints_name}",
          "name": "${var.Private_Endpoints_name}",
          "location": "${var.location}",
          "properties": {
            "privateLinkServiceConnections": [
              {
                "id": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Network/privateEndpoints/privateLinkServiceConnections/${var.Private_Endpoints_name}_${random_id.private_link_service_connection_id.hex}",
                "name": "${var.Private_Endpoints_name}_${random_id.private_link_service_connection_id.hex}",
                "properties": {
                  "privateLinkServiceId": "/subscriptions/steps('basics').resourceScope.subscription.id/resourceGroups/steps('basics').resourceScope.resourceGroup.id/providers/Microsoft.OpenEnergyPlatform/energyServices",
                  "groupIds": [
                    "Azure Data Manager for Energy"
                  ]
                }
              }
            ],
            "manualPrivateLinkServiceConnections": [],
            "subnet": {
              "id": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Network/virtualNetworks/${var.adme_vnet_name}/subnets/${var.adme_vnet_subnet_name}"
            }
          },
          "type": "Microsoft.Network/privateEndpoints",
          "tags": {}
        },
        "subResource": {
          "groupId": "Azure Data Manager for Energy",
          "expectedPrivateDnsZoneName": "[privatelink.energy.azure.com,privatelink.blob.core.windows.net]",
          "subResourceDisplayName": "Azure Data Manager for Energy"
        }
      }]
    }
    "resourceGroupId" ={
      value = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"}
  })

  template_content    = file("template.json")
  depends_on = [
    azurerm_subnet.adme,
    null_resource.delete_private_dns_link_for_energy,
    null_resource.delete_private_dns_link_for_blob
  ]
}