// This creates the "workflow.json" file in the local directory
// This should be modified manually after performing steps listed in the README.md 
resource "local_file" "workflow" {
    content  = <<EOH
{
    "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {
            "DecodeBase64": {
                "inputs": "@decodeBase64(body('HTTP').$Content)",
                "runAfter": {
                    "HTTP": [
                        "Succeeded"
                    ]
                },
                "type": "Compose"
            },
            "Delay": {
                "inputs": {
                    "interval": {
                        "count": 10,
                        "unit": "Minute"
                    }
                },
                "runAfter": {},
                "type": "Wait"
            },
            "For_each": {
                "actions": {
                    "Compose": {
                        "inputs": {
                            "ipv4addr": "@{items('For_each')}"
                        },
                        "runAfter": {},
                        "type": "Compose"
                    },
                    "Watchlists_-_Add_a_new_Watchlist_Item": {
                        "inputs": {
                            "body": "@outputs('Compose')",
                            "host": {
                                "connection": {
                                    "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                                }
                            },
                            "method": "put",
                            "path": "/Watchlists/subscriptions/@{encodeURIComponent('${var.subscription_id}')}/resourceGroups/@{encodeURIComponent('${var.rg_name}')}/workspaces/@{encodeURIComponent('${var.workspace_id}')}/watchlists/@{encodeURIComponent('${var.watchlist_name}')}/watchlistItem"
                        },
                        "runAfter": {
                            "Compose": [
                                "Succeeded"
                            ]
                        },
                        "type": "ApiConnection"
                    }
                },
                "foreach": "@body('Parse_JSON')?['ipv4Addresses']",
                "runAfter": {
                    "Parse_JSON": [
                        "Succeeded"
                    ]
                },
                "type": "Foreach"
            },
            "HTTP": {
                "inputs": {
                    "method": "GET",
                    "uri": "https://reputation.alienvault.com/reputation.generic"
                },
                "runAfter": {
                    "Watchlists_-_Create_a_new_Watchlist_with_data_(Raw_Content)": [
                        "Succeeded"
                    ]
                },
                "type": "Http"
            },
            "ParseIP": {
                "inputs": {
                    "body": "@outputs('DecodeBase64')",
                    "function": {
                        "id": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Web/sites/${azurerm_windows_function_app.IOCParser-Alienvault.name}/functions/${azurerm_function_app_function.IOCParserHTTP.name}"
                    }
                },
                "runAfter": {
                    "DecodeBase64": [
                        "Succeeded"
                    ]
                },
                "type": "Function"
            },
            "Parse_JSON": {
                "inputs": {
                    "content": "@body('ParseIP')",
                    "schema": {
                        "properties": {
                            "ipv4Addresses": {
                                "items": {
                                    "type": "string"
                                },
                                "type": "array"
                            }
                        },
                        "type": "object"
                    }
                },
                "runAfter": {
                    "ParseIP": [
                        "Succeeded"
                    ]
                },
                "type": "ParseJson"
            },
            "Watchlists_-_Create_a_new_Watchlist_with_data_(Raw_Content)": {
                "inputs": {
                    "body": {
                        "description": "IPv4 from Alienvault",
                        "displayName": "${var.watchlist_name}",
                        "itemsSearchKey": "ipv4addr",
                        "rawContent": "ipv4addr\r\n255.255.255.255"
                    },
                    "host": {
                        "connection": {
                            "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                        }
                    },
                    "method": "put",
                    "path": "/Watchlists/subscriptions/@{encodeURIComponent('${var.subscription_id}')}/resourceGroups/@{encodeURIComponent('${var.rg_name}')}/workspaces/@{encodeURIComponent('${var.workspace_id}')}/watchlists/@{encodeURIComponent('${var.watchlist_name}')}"
                },
                "runAfter": {
                    "Delay": [
                        "Succeeded"
                    ]
                },
                "type": "ApiConnection"
            },
            "Watchlists_-_Delete_a_Watchlist": {
                "inputs": {
                    "host": {
                        "connection": {
                            "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                        }
                    },
                    "method": "delete",
                    "path": "/Watchlists/subscriptions/@{encodeURIComponent('${var.subscription_id}')}/resourceGroups/@{encodeURIComponent('${var.rg_name}')}/workspaces/@{encodeURIComponent('${var.workspace_id}')}/watchlists/@{encodeURIComponent('${var.watchlist_name}')}"
                },
                "runAfter": {},
                "type": "ApiConnection"
            }
        },
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "parameters": {
            "$connections": {
                "defaultValue": {},
                "type": "Object"
            }
        },
        "triggers": {
            "Recurrence": {
                "evaluatedRecurrence": {
                    "frequency": "Hour",
                    "interval": 24
                },
                "recurrence": {
                    "frequency": "Hour",
                    "interval": 24
                },
                "type": "Recurrence"
            }
        }
    },
    "parameters": {
        "$connections": {
            "value": {
                "azuresentinel": {
                    "connectionId": "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}/providers/Microsoft.Web/connections/azuresentinel-6",
                    "connectionName": "azuresentinel-6",
                    "id": "/subscriptions/${var.subscription_id}/providers/Microsoft.Web/locations/eastus/managedApis/azuresentinel"
                }
            }
        }
    }
}
EOH
    filename = "./workflow.json"
}