locals {  
  tags = {
    environment = var.environment
    created     = timestamp()
    creator     = var.creator
  }
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "resources" {
  name     = var.resource-group
  location = var.location
}

/******************/
/* Azure AD Group */
/******************/

resource "azuread_group" "sql-admin-group" {
  display_name            = "demo-passwordless-sql-admin-group"
  description             = "SQL Administrators for passwordless DB demo"
  prevent_duplicate_names = true
  security_enabled        = true
  members                 = var.aad-sql-admins
}

/********************/
/* Spring Cloud App */
/********************/

resource "azurerm_spring_cloud_service" "springcloud" {
  name                = "demo-passwordless-springcloud"
  resource_group_name = azurerm_resource_group.resources.name
  location            = azurerm_resource_group.resources.location
}

resource "azurerm_spring_cloud_app" "example" {
  name                = "demo-passwordless-springcloudapp"
  resource_group_name = azurerm_resource_group.resources.name
  service_name        = azurerm_spring_cloud_service.springcloud.name

  identity {
    type = "SystemAssigned"
  }
}

/****************/
/* Azure MS SQL */
/****************/

resource "azurerm_mssql_server" "sqlserver" {
  name                = "demo-passwordless-sqlserver"
  resource_group_name = azurerm_resource_group.resources.name
  location            = azurerm_resource_group.resources.location

  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    azuread_authentication_only = true
    login_username              = azuread_group.sql-admin-group.display_name
    object_id                   = azuread_group.sql-admin-group.object_id
  }

  tags = local.tags
}

resource "azurerm_mssql_database" "database" {
  name      = "demo-passwordless-sqldb"
  server_id = azurerm_mssql_server.sqlserver.id

  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  storage_account_type = "Local"
  max_size_gb          = 4
  sku_name             = "S0"

  tags = local.tags
}

# resource "null_resource" "provision" {
#   depends_on = [azurerm_mssql_database.database, azuread_group.sql-admin-group]

#   provisioner "local-exec" {
#     command = <<EOT
#         docker run --rm \
#         --platform=linux/amd64 \
#         -v ${path.cwd}/${path.module}/dist/db-maintenance-user.sql:/tmp/db-maintenance-user.sql \
#         -i mcr.microsoft.com/mssql-tools /opt/mssql-tools/bin/sqlcmd \
#         -U "${var.db_server_login}" \
#         -P "${var.db_server_password}" \
#         -S ${var.db.server_name}.database.windows.net \
#         -d ${var.db.instance} \
#         -i /tmp/db-maintenance-user.sql \
#         > sqlcmd.log
#     EOT
#   }
# }