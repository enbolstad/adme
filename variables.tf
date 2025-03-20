variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg10"
}

variable "subscription_id" {
  description = "The subscription id"
  type        = string
  default     = "417b4d8b-8673-4b95-9e59-429818b22af1"

}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "northeurope"

}

variable "authAppId" {
  description = "The auth app id"
  type        = string
  default     = "f37be710-de99-4d1d-bc62-8f5cde53d030"

}

variable "adme_name" {
  description = "The name of the adme instance"
  type        = string
  default     = "testdewhgsyghh"

}

variable "tenant_id" {
  description = "The Id of entraID tenant"
  type        = string
  default     = "8b87af7d-8647-4dc7-8df4-5f69a2011bb5"

}

variable "subscription_display_name" {
  description = "The display name of the subscription"
  type        = string
  default     = "ADME Playground"

}

variable "Private_Endpoints_name" {
  description = "The display name of the Private Endpoint"
  type        = string
  default     = "PrivateEndpoint738"

}

variable "adme_vnet_name" {
  description = "Name of the vnet where the Private Endpoint will be created"
  type        = string
  default     = "vnet_adme"

}

variable "adme_vnet_subnet_name" {
  description = "Name of the subnet where the Private Endpoint will be created"
  type        = string
  default     = "default"

}

variable "adme_datapartition_name1" {
  description = "Name of the data partition"
  type        = string
  default     = "dp1"

}

variable "adme_sku" {
  description = "The sku of the adme instance"
  type        = string
  default     = "Developer"

  validation {
    condition     = contains(["Developer", "Standard"], var.adme_sku)
    error_message = "The sku must be either 'Developer' or 'Standard'."
  }

}