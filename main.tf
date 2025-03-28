resource "azurerm_resource_group" "default" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_resource_group" "osdu_service_log" {
  name     = var.rg_name_osdu_service_log
  location = var.location
}


resource "azurerm_resource_group_template_deployment" "default" {
  name                = var.adme_name
  resource_group_name = azurerm_resource_group.default.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
    value = "${var.adme_name}" }
    "location" = {
    value = "${var.location}" }
    "tagsByResource" = {
      value = {}
    }
    "authAppId" = {
      value = "${var.authAppId}"
    }
    "dataPartitionNames" = {
      value = [
        {
          "name" = "${var.adme_datapartition_name1}"
        }
      ]
    }
    "cmkEnabled" = {
    value = false }
    "encryption" = {
    value = {} }
    "identity" = {
    value = {} }
    "corsRules" = {
    value = [] }
    "sku" = {
      value = {
        "name" = "${var.adme_sku}"
      }
    }
    "publicNetworkAccess" = {
    value = true }
    "privateEndpoints" = {
      value = []
    }
    "resourceGroupId" = {
    value = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}" }
  })

  template_content = file("template.json")
}

#Storage and workspace for osdu service logs

resource "azurerm_storage_account" "adme_log" {
  name                     = "99akerbpadmepwe01"
  resource_group_name      = azurerm_resource_group.osdu_service_log.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_log_analytics_workspace" "osdu_service_logs" {
  name                = "ws-msa-adme-mon-prod-we-999"
  location            = var.location
  resource_group_name = azurerm_resource_group.osdu_service_log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_container" "osdu_service_logs" {
  name                  = "osduservicelogs"
  storage_account_id    = azurerm_storage_account.adme_log.id
  container_access_type = "private"
}