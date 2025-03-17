terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.22.0"
    }
  }
  backend "azurerm" {
    key                  = "github.terraform.tfstate"
  }

  required_version = ">=0.12"
}
provider "azurerm" {
  features {}
  # Configuration options
}
 