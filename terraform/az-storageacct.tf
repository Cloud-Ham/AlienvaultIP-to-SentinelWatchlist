// Creates the Storage Account for the Function App
resource "azurerm_storage_account" "IOCParserFunctionStorage" {
  name                     = "iocalienvault${random_string.storage.result}"
  resource_group_name      = var.rg_name
  location                 = var.deploy_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}