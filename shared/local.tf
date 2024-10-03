locals {
  resource_group_name = "rg-sander-shared-${var.env}-01"

  # Managed Identity
  shared_identity_name = "mi-sander-shared-${var.env}-01"

  # Networking
  vnet = {
    name = "vnet-sander-shared-${var.env}-01"
    subnets = {
      chess_env = {
        name = "subnet-cntenv-sander-chess-${var.env}-01"
        ips  = ["10.0.2.0/23"]
      }
      sql = {
        name = "subnet-sql-sander-shared-${var.env}-01"
        ips  = ["10.0.4.0/24"]
      }
    }
    nsgs = {
      sql_name       = "nsg-sql-sander-shared-${var.env}-01"
      chess_env_name = "nsg-cntenv-sander-chess-${var.env}-01"
    }
  }

  # Key Vault
  key_vault = {
    name     = "kv-sander-shared-${var.env}-05"
    sku_name = "standard"
  }

  sql = {
    admin_name  = "sanderkt"
    server_name = "sqlsrv-sander-shared-${var.env}-03"
  }

  storage = {
    name = "stsanderchess${var.env}01"
  }

}
