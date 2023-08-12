// Creates the initial Logic App without any triggers or actions
// See the README.md for steps to take after the deployment is completed
resource "azurerm_logic_app_workflow" "AlienvaultIOCWatchlistBuilder" {
    name = "AlienvaultIOCWatchlistBuilder"
    location            = var.deploy_location
    resource_group_name = var.rg_name
}