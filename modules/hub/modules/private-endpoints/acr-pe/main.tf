/*
  main.tf (Hub Private Endpoint - ACR)

  This file provisions the private endpoint for Azure Container Registry (ACR) in the Kelix Azure Hub environment.
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
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.hub_pe_acr_location
  resource_group_name = var.hub_pe_acr_resource_group_name
  subnet_id           = var.hub_pe_acr_subnet_id

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-${random_string.psc_suffix.result}"
    private_connection_resource_id = var.hub_pe_acr_id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_pl.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.hub_pe_acr_pe_random_suffix_length
  special = var.hub_pe_acr_pe_random_suffix_special
  upper   = var.hub_pe_acr_pe_random_suffix_upper
}

resource "random_string" "psc_suffix" {
  length  = var.hub_pe_acr_psc_random_suffix_length
  special = var.hub_pe_acr_psc_random_suffix_special
  upper   = var.hub_pe_acr_psc_random_suffix_upper
}

resource "random_string" "dns_group_suffix" {
  length  = var.hub_pe_acr_dns_group_random_suffix_length
  special = var.hub_pe_acr_dns_group_random_suffix_special
  upper   = var.hub_pe_acr_dns_group_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "acr_pl" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.hub_pe_acr_resource_group_name
}