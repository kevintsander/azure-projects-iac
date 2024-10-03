data "azurerm_key_vault" "key_vault" {
  name                = local.key_vault.name
  resource_group_name = local.shared_rg_name
}

data "azurerm_key_vault_secret" "key_vault_secret" {
  for_each     = local.key_vault.secret_names
  name         = each.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_user_assigned_identity" "shared_identity" {
  name                = local.shared_identity_name
  resource_group_name = local.shared_rg_name
}

data "azurerm_virtual_network" "vnet" {
  name                = local.vnet.name
  resource_group_name = local.shared_rg_name
}

data "azurerm_subnet" "container_env_subnet" {
  name                 = local.vnet.subnets.container_env.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.shared_rg_name
}
