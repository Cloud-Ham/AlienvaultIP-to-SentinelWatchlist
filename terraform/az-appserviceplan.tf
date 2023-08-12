resource "azurerm_service_plan" "IOCParserAlienvaultASP" {
    name                = "IOCParserAlienvaultASP"
    resource_group_name = var.rg_name
    location            = var.deploy_location
    os_type             = "Windows"
    sku_name            = "Y1"
}