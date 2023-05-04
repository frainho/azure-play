# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "azure_play_rg"
    storage_account_name = "tfstatestoreageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "azure_play_rg"
  location = "westeurope"
}

#### Store tf state in storage account
resource "azurerm_storage_account" "tfstate_storage_account" {
  name                     = "tfstatestoreageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfcontainer" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate_storage_account.name
  container_access_type = "private"
}

##### Azure Function App
resource "azurerm_storage_account" "app_fn_storage_account" {
  name                     = "appfnstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "app_fn_service_plan" {
  name                = "appfnserviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "app_function" {
  name                = "appfnlinux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.app_fn_storage_account.name
  storage_account_access_key = azurerm_storage_account.app_fn_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.app_fn_service_plan.id

  site_config {}
}

###### Azure container registry
resource "azurerm_container_registry" "acr" {
  name                = "acrazureplay"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}
