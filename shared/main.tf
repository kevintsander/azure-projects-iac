resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

# Networking
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_chess_env" {
  name                 = local.vnet.subnets.chess_env.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.vnet.subnets.chess_env.ips
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql"]
}

resource "azurerm_network_security_group" "nsg_chess_env" {
  name                = local.vnet.nsgs.chess_env_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHttpInternetInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_chess_env_nsg" {
  subnet_id                 = azurerm_subnet.subnet_chess_env.id
  network_security_group_id = azurerm_network_security_group.nsg_chess_env.id
}

# Managed Identity
resource "azurerm_user_assigned_identity" "shared_identity" {
  name                = local.shared_identity_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                      = local.key_vault.name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = local.key_vault.sku_name
  enable_rbac_authorization = true

  network_acls {
    bypass                     = "None"
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnet_chess_env.id]

    ip_rules = ["72.49.218.202"]
  }
}

# Key Vault RBAC
resource "azurerm_role_assignment" "shared_identity_kv_reader" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_user_assigned_identity.shared_identity.principal_id
}

resource "azurerm_role_assignment" "shared_identity_kv_officer" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.shared_identity.principal_id
}

# takes forever?
# resource "azurerm_role_assignment" "kv_admin" {
#   scope                = azurerm_key_vault.key_vault.id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = var.my_id
# }

# Storage
# resource "azurerm_storage_account" "storage" {
#   name                            = local.storage.name
#   resource_group_name             = azurerm_resource_group.rg.name
#   location                        = azurerm_resource_group.rg.location
#   account_tier                    = "Standard"
#   account_replication_type        = "LRS"
#   allow_nested_items_to_be_public = false
# }

# resource "azurerm_storage_container" "tfstate-container" {
#   name                  = "tfstate"
#   storage_account_name  = azurerm_storage_account.storage.name
#   container_access_type = "private"
# }
