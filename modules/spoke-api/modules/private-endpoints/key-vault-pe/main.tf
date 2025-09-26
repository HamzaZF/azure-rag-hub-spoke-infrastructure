
# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "api"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${module.naming.private_endpoint.name}-${random_string.pe_suffix.result}"
  location            = var.spoke_api_pe_key_vault_location
  resource_group_name = var.spoke_api_pe_key_vault_resource_group_name
  subnet_id           = var.spoke_api_pe_key_vault_subnet_id

  private_service_connection {
    name                           = "api-key-vault-psc"
    private_connection_resource_id = var.spoke_api_pe_key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_pl.id]
  }
}

resource "random_string" "pe_suffix" {
  length  = var.spoke_api_pe_key_vault_pe_random_suffix_length
  special = var.spoke_api_pe_key_vault_pe_random_suffix_special
  upper   = var.spoke_api_pe_key_vault_pe_random_suffix_upper
}

resource "random_string" "dns_group_suffix" {
  length  = var.spoke_api_pe_key_vault_dns_group_random_suffix_length
  special = var.spoke_api_pe_key_vault_dns_group_random_suffix_special
  upper   = var.spoke_api_pe_key_vault_dns_group_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "kv_pl" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.spoke_api_pe_key_vault_resource_group_name
}