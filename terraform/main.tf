terraform {
    required_providers {
    azurerm = {
            source  = "hashicorp/azurerm"
            version = "=3.68.0"
        }
    local = {
        source = "hashicorp/local"
        version = "2.2.3"
    }
    }
}

provider "azurerm" {
    features{}
}

// Random String used for the StorageAccount naming
resource "random_string" "storage" {
    length  = 11
    special = false
    upper   = false
}

// Random String used for the FunctionApp naming
resource "random_string" "function" {
    length  = 20
    special = false
    upper   = false
}

