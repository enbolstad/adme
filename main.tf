resource "azurerm_resource_group" "default" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_resource_group_template_deployment" "default" {
  name                = var.adme_name
  resource_group_name = azurerm_resource_group.default.name
  deployment_mode     = "Incremental"
  template_content = file("template.json")
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
    "resourceGroupId" = {
    value = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}" }
  })
}