provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


#Configure Terraform to Use Remote State
terraform {
  backend "azurerm" {
    resource_group_name  = "state-rg"
    storage_account_name = "ur6urur"
    container_name       = "stagecontainer"
    key                  = "terraform.tfstate"
  }
}
