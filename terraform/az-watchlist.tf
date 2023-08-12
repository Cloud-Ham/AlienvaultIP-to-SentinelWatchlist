// This creates the initial watchlist with a dummy value in it. 
// For more info on why the dummy value exists, check the README.md file

// Creates new Sentinel Watchlist
resource "azurerm_sentinel_watchlist" "AlienvaultIPList" {
    name                       = var.watchlist_name
    description                = "A list of IPv4 Addresses fed in from the IOCParser-Alienvault Logic App"
    log_analytics_workspace_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.OperationalInsights/workspaces/${var.workspace_name}"
    display_name               = var.watchlist_name
    item_search_key            = "Ipv4addr"
}

// Adds a dummy value to the Sentinel Watchlist
resource "azurerm_sentinel_watchlist_item" "AlienvaultIPList-dummy" {
    watchlist_id = azurerm_sentinel_watchlist.AlienvaultIPList.id
    properties = {
        Ipv4addr = "999.999.999.999"
    }
}