/*
  main.tf (Hub Private Endpoint - Blob Storage)

  This file provisions the private endpoint for Blob Storage in the Kelix Azure Hub environment.
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
resource "azurerm_private_endpoint" "kelix_storage_blob" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.hub_pe_blob_storage_location
  resource_group_name = var.hub_pe_blob_storage_resource_group_name
  subnet_id           = var.hub_pe_blob_storage_subnet_id

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-${random_string.psc_suffix.result}"
    private_connection_resource_id = var.hub_pe_blob_storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  # DNS Zone Group for automatic A-record injection
  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob_pl.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.hub_pe_blob_storage_pe_random_suffix_length
  special = var.hub_pe_blob_storage_pe_random_suffix_special
  upper   = var.hub_pe_blob_storage_pe_random_suffix_upper
}

resource "random_string" "psc_suffix" {
  length  = var.hub_pe_blob_storage_psc_random_suffix_length
  special = var.hub_pe_blob_storage_psc_random_suffix_special
  upper   = var.hub_pe_blob_storage_psc_random_suffix_upper
}

resource "random_string" "dns_group_suffix" {
  length  = var.hub_pe_blob_storage_dns_group_random_suffix_length
  special = var.hub_pe_blob_storage_dns_group_random_suffix_special
  upper   = var.hub_pe_blob_storage_dns_group_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "storage_blob_pl" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.hub_pe_blob_storage_resource_group_name
}