resource "azurerm_role_assignment" "aks_identity_role" {
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "aks_dns_role" {
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Private DNS Zone Contributor"
  scope                = azurerm_private_dns_zone.aks_zone.id
}


resource "azurerm_role_assignment" "network_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_virtual_network.vnet.id
}
