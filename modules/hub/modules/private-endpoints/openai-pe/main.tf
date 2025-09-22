/*
  main.tf (Hub Private Endpoint - OpenAI)

  This file provisions the private endpoint for OpenAI in the Kelix Azure Hub environment.
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
resource "azurerm_private_dns_zone" "openai_dns_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.hub_pe_openai_resource_group_name
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "openai_private_endpoint" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.hub_pe_openai_location
  resource_group_name = var.hub_pe_openai_resource_group_name
  subnet_id           = var.hub_pe_openai_subnet_id

  private_service_connection {
    name                           = "openai-private-connection"
    private_connection_resource_id = var.hub_pe_openai_cognitive_account_id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai_dns_zone.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.hub_pe_openai_pe_random_suffix_length
  special = var.hub_pe_openai_pe_random_suffix_special
  upper   = var.hub_pe_openai_pe_random_suffix_upper
}