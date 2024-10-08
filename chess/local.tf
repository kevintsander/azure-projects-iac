locals {
  app_name = "chess"

  resource_group_name = "rg-sander-chess-${var.env}-01"

  key_vault = {
    name = "kv-sander-shared-${var.env}-05"
    secret_names = {
      sql_server_admin_password = "chess-sql-server-admin-password",
    }
  }

  sql = {
    server_name = "sqlsrv-sander-shared-${var.env}-03"
    db_name     = "chess-${var.env}-01"
    admin_name  = "sanderkt"
  }

  api = {
    name = "cntapp-sander-chess-${var.env}-03"
    container = {
      name     = "chess-api"
      env_name = "cntenv-sander-chess-01"
    }
  }

  ui = {
    name = "stwebapp-sander-chess-dev-01"
  }

  tags = {
    Purpose = "Chess API"
  }

  # Data Source Variables
  shared_identity_name = "mi-sander-shared-${var.env}-01"
  shared_rg_name       = "rg-sander-shared-${var.env}-01"

  vnet = {
    name = "vnet-sander-shared-${var.env}-01"
    subnets = {
      container_env = {
        name = "subnet-cntenv-sander-chess-${var.env}-01"
      }
      sql = {
        name = "subnet-sql-sander-shared-${var.env}-01"
      }
    }
  }
}
