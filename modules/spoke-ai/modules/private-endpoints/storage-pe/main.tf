/*
  main.tf (Spoke AI Private Endpoint - Storage)

  This file provisions the private endpoint for Azure Storage Account in the Kelix Azure Spoke AI environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "ai"]
  suffix = [var.naming_region]
}

# Random string for DNS zone link uniqueness
resource "random_string" "dns_link_suffix" {
  length  = 8
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.spoke_ai_pe_storage_location
  resource_group_name = var.spoke_ai_pe_storage_resource_group_name
  subnet_id           = var.spoke_ai_pe_storage_subnet_id

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-${random_string.psc_suffix.result}"
    private_connection_resource_id = var.spoke_ai_pe_storage_account_id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = var.spoke_ai_pe_storage_private_dns_zone_id != null ? [var.spoke_ai_pe_storage_private_dns_zone_id] : [azurerm_private_dns_zone.storage_dns_zone.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.spoke_ai_pe_storage_pe_random_suffix_length
  special = var.spoke_ai_pe_storage_pe_random_suffix_special
  upper   = var.spoke_ai_pe_storage_pe_random_suffix_upper
}

resource "random_string" "psc_suffix" {
  length  = var.spoke_ai_pe_storage_psc_random_suffix_length
  special = var.spoke_ai_pe_storage_psc_random_suffix_special
  upper   = var.spoke_ai_pe_storage_psc_random_suffix_upper
}

resource "random_string" "dns_group_suffix" {
  length  = var.spoke_ai_pe_storage_dns_group_random_suffix_length
  special = var.spoke_ai_pe_storage_dns_group_random_suffix_special
  upper   = var.spoke_ai_pe_storage_dns_group_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "storage_dns_zone" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = var.spoke_ai_pe_storage_resource_group_name
}