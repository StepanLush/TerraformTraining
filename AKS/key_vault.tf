resource "azurerm_key_vault" "kv" {
  name                = "aks-keyvault-2352"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aks_identity.client_id

    secret_permissions = ["Get", "List", "Set"]
    key_permissions    = ["Get", "List"]
  }


  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set"]
  }


  tags = {
    environment = "production"
  }
}


data "azurerm_client_config" "current" {}
