// Create the Function App on Node.js 18
resource "azurerm_windows_function_app" "IOCParser-Alienvault" {
    name                = "IOCParser-Alienvault-${random_string.function.result}"
    resource_group_name = var.rg_name
    location            = var.deploy_location

    storage_account_name       = azurerm_storage_account.IOCParserFunctionStorage.name
    storage_account_access_key = azurerm_storage_account.IOCParserFunctionStorage.primary_access_key
    service_plan_id            = azurerm_service_plan.IOCParserAlienvaultASP.id

    site_config {
        application_stack {
            node_version = "~18"
        }
    }
}

// Create the Function App's Function, "IOCParserHTTP"
resource "azurerm_function_app_function" "IOCParserHTTP" {
    name  = "IOCParserHTTP"
    function_app_id = azurerm_windows_function_app.IOCParser-Alienvault.id 
    language = "Javascript"

    file {
        name = "index.js"
        content = file("script/index.js")
    }
    // Leaving this here for future reference, the config_json block is required but can
    // be overwritten by specifying the file commented out.
    /*
    file {
        name = "function.json"
        content = file("script/function.json")
    }
    */
    config_json = jsonencode({
    "bindings": [
        {
            "authLevel": "function",
            "type": "httpTrigger",
            "direction": "in",
            "name": "req",
            "methods": [
                "get",
                "post"
            ]
        },
        {
            "type": "http",
            "direction": "out",
            "name": "res"
        }
    ]
})
}
