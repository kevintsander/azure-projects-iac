resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

# Container
resource "azurerm_container_app_environment" "container_env" {
  name                     = local.api.container.env_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  tags                     = local.tags
  infrastructure_subnet_id = data.azurerm_subnet.container_env_subnet.id
}

resource "azurerm_container_app" "api" {
  name                         = local.api.name
  container_app_environment_id = azurerm_container_app_environment.container_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # identity {
  #   type = "SystemAssigned"
  # }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.shared_identity.id]
  }

  # secret {
  #   name                = local.key_vault.secret_names.sql_server_admin_password
  #   key_vault_secret_id = data.azurerm_key_vault_secret.key_vault_secret["sql_server_admin_password"].versionless_id
  #   identity            = data.azurerm_user_assigned_identity.shared_identity.id
  # }

  template {
    container {
      name   = local.api.name
      cpu    = 0.25
      memory = "0.5Gi"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld" // placeholder, will be replaced on app deployment


      # env {
      #   name  = "CHESS_SQL_DB_NAME"
      #   value = local.sql.db_name
      # }

      # env {
      #   name  = "CHESS_SQL_HOST"
      #   value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
      # }

      # env {
      #   name  = "CHESS_SQL_PORT"
      #   value = local.sql.port
      # }

      # env {
      #   name  = "CHESS_SQL_USERNAME"
      #   value = local.sql.admin_name
      # }

      # env {
      #   name        = "CHESS_SQL_PASSWORD"
      #   secret_name = local.key_vault.secret_names.sql_server_admin_password
      # }

      # env {
      #   name  = "CHESS_SQL_AZURE"
      #   value = "true"
      # }

    }
  }

  ingress {
    target_port      = 3000
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    ip_security_restriction {
      name             = "My IP"
      action           = "Allow"
      ip_address_range = "72.49.218.202"
    }
  }

  tags = local.tags
}

resource "azuread_application_registration" "app_reg" {
  display_name = local.app_name
}

resource "azuread_service_principal" "app_sp" {
  client_id = azuread_application_registration.app_reg.client_id
}

resource "azurerm_role_assignment" "shared_identity_role_assignment" {
  principal_id         = azuread_service_principal.app_sp.object_id
  role_definition_name = "Managed Identity Operator"
  scope                = data.azurerm_user_assigned_identity.shared_identity.id
}

resource "azurerm_role_assignment" "app_sp_key_vault_officer" {
  principal_id         = azuread_service_principal.app_sp.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_role_assignment" "app_sp_chess_rg_contributor" {
  principal_id         = azuread_service_principal.app_sp.object_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

# SQL
# TODO - move this to shared
resource "azurerm_mssql_server" "sql_server" {
  name                          = local.sql.server_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = local.sql.admin_name
  administrator_login_password  = data.azurerm_key_vault_secret.key_vault_secret["sql_server_admin_password"].value
  public_network_access_enabled = true

  tags = local.tags
}

resource "azurerm_mssql_firewall_rule" "sql_server_firewall_rule_myip" {
  name             = "AllowMyIP"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "72.49.218.202"
  end_ip_address   = "72.49.218.202"
}

resource "azurerm_mssql_virtual_network_rule" "sql_server_vnet_rule" {
  name      = "${local.sql.server_name}-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = data.azurerm_subnet.container_env_subnet.id
}

resource "azurerm_mssql_database" "sql_db" {
  name      = local.sql.db_name
  server_id = azurerm_mssql_server.sql_server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"

  sku_name                    = "GP_S_Gen5_1"
  auto_pause_delay_in_minutes = 60
  zone_redundant              = false
  max_size_gb                 = 32
  min_capacity                = 0.5
  read_replica_count          = 0
  read_scale                  = false
  storage_account_type        = "Local"
  tags                        = local.tags

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_static_web_app" "ui" {
  name                = local.ui.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2" // not available in north central currently
}
