locals {
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
    port        = 1433
    admin_name  = "sanderkt"
  }

  app = {
    name = "cntapp-sander-chess-${var.env}-01"
    container = {
      name     = "chess-api"
      env_name = "cntenv-sander-chess-01"
      registry = {
        image    = "kevintsander/chess-api:main"
        server   = "ghcr.io"
        username = "kevintsander@gmail.com"
      }
    }
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
