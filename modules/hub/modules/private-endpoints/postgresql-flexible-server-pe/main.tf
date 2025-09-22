/*
  main.tf (Hub Private Endpoint - PostgreSQL Flexible Server)

  This file provisions the private endpoint for PostgreSQL Flexible Server in the Kelix Azure Hub environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "psql_pe" {
  name                = "${var.hub_pe_postgresql_server_name}-pe"
  location            = var.hub_pe_postgresql_location
  resource_group_name = var.hub_pe_postgresql_resource_group_name
  subnet_id           = var.hub_pe_postgresql_subnet_id

  private_service_connection {
    name                           = "${var.hub_pe_postgresql_server_name}-psc"
    private_connection_resource_id = var.hub_pe_postgresql_server_id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres_pl.id]
  }
}

resource "random_string" "dns_group_suffix" {
  length  = var.hub_pe_postgresql_dns_group_random_suffix_length
  special = var.hub_pe_postgresql_dns_group_random_suffix_special
  upper   = var.hub_pe_postgresql_dns_group_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "postgres_pl" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.hub_pe_postgresql_resource_group_name
}