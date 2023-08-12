// Variable for Resource Group
variable "rg_name" {
    type = string
}

// Variable for Deployment Location (ex. "east us")
variable "deploy_location" {
    type = string
}

// Variable for Azure Subscription ID
variable "subscription_id" {
    type = string
}

// Variable for Log Analytics Workspace ID
variable "workspace_id" {
    type = string
}

// Variable for Log Analytics Workspace Name
variable "workspace_name" {
    type = string
}

// Variable for Sentinel Watchlist Name
variable "watchlist_name" {
    type = string
}