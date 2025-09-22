/*
  main.tf (Hub Private Endpoint - Azure AI Search)

  This file provisions the private endpoint for Azure AI Search in the Kelix Azure Hub environment.
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
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "search_dns_zone" {
  name                = "privatelink.search.windows.net"
  resource_group_name = var.hub_pe_ai_search_resource_group_name
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "search_private_endpoint" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.hub_pe_ai_search_location
  resource_group_name = var.hub_pe_ai_search_resource_group_name
  subnet_id           = var.hub_pe_ai_search_subnet_id

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-${random_string.psc_suffix.result}"
    private_connection_resource_id = var.hub_pe_ai_search_service_id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.search_dns_zone.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.hub_pe_ai_search_pe_random_suffix_length
  special = var.hub_pe_ai_search_pe_random_suffix_special
  upper   = var.hub_pe_ai_search_pe_random_suffix_upper
}

resource "random_string" "psc_suffix" {
  length  = var.hub_pe_ai_search_psc_random_suffix_length
  special = var.hub_pe_ai_search_psc_random_suffix_special
  upper   = var.hub_pe_ai_search_psc_random_suffix_upper
}