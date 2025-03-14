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

resource "azurerm_resource_group_template_deployment" "default" {
  name                = var.adme_name
  resource_group_name = azurerm_resource_group.default.name
  deployment_mode     = "Incremental"
      depends_on = [
    azurerm_subnet.adme
  ]
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
        "name"="dp1"}
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
      "name" = "Developer"
      }
    }
    "publicNetworkAccess" = {
      value =true}
    "privateEndpoints" = {
      value =[
                {
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
                                    "id": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Network/privateEndpoints/privateLinkServiceConnections/${var.Private_Endpoints_name}_b7efbe6a-12bf-4a1c-80ba-043454ba3015",
                                    "name": "${var.Private_Endpoints_name}_b7efbe6a-12bf-4a1c-80ba-043454ba3015",
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
                }
            ] }
    "resourceGroupId" ={
      value = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"}
  })

  template_content    = file("template.json")
  }





/* resource "azurerm_virtual_network" "appgw" {
  name                = "vn_appgw"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "subnet_appgw"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.appgw.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appgw.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appgw.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appgw.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appgw.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appgw.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appgw.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.appgw.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgw"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled = true
    firewall_mode = "Prevention"
    rule_set_type = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name

  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
} */