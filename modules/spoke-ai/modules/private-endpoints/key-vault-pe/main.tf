/*
  main.tf - Spoke AI Key Vault Private Endpoint Module

  This module creates a private endpoint for the AI spoke Key Vault,
  enabling secure, private connectivity from the container apps subnet
  and other authorized networks within the Azure environment.

  Components:
  - Private endpoint for Key Vault
  - Private DNS zone for key vault resolution
  - DNS zone group for automatic record management
  - Integration with spoke AI networking
*/

# =============================================================================
# NAMING
# =============================================================================
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "ai"]
  suffix = [var.naming_region]
}

# =============================================================================
# PRIVATE ENDPOINT
# =============================================================================
# Private endpoint for secure Key Vault access

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${module.naming.private_endpoint.name}-kv-${random_string.pe_suffix.result}"
  location            = var.spoke_ai_pe_key_vault_location
  resource_group_name = var.spoke_ai_pe_key_vault_resource_group_name
  subnet_id           = var.spoke_ai_pe_key_vault_subnet_id

  private_service_connection {
    name                           = "kelix-ai-key-vault-psc"
    private_connection_resource_id = var.spoke_ai_pe_key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${module.naming.private_dns_zone_group.name}-kv-${random_string.dns_group_suffix.result}"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }

  tags = merge(
    var.spoke_ai_pe_key_vault_tags,
    {
      Environment = var.naming_environment
      Purpose     = "ContainerApps-KeyVault-PrivateEndpoint"
      Spoke       = "AI"
    }
  )
}

# =============================================================================
# RANDOM SUFFIXES
# =============================================================================
# Random suffixes for unique naming

resource "random_string" "pe_suffix" {
  length  = var.spoke_ai_pe_key_vault_pe_random_suffix_length
  special = var.spoke_ai_pe_key_vault_pe_random_suffix_special
  upper   = var.spoke_ai_pe_key_vault_pe_random_suffix_upper
}

resource "random_string" "dns_group_suffix" {
  length  = var.spoke_ai_pe_key_vault_dns_group_random_suffix_length
  special = var.spoke_ai_pe_key_vault_dns_group_random_suffix_special
  upper   = var.spoke_ai_pe_key_vault_dns_group_random_suffix_upper
}

# =============================================================================
# PRIVATE DNS ZONE
# =============================================================================
# Private DNS zone for Key Vault private link resolution

resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.spoke_ai_pe_key_vault_resource_group_name

  tags = merge(
    var.spoke_ai_pe_key_vault_tags,
    {
      Environment = var.naming_environment
      Purpose     = "ContainerApps-KeyVault-DNS"
      Spoke       = "AI"
    }
  )
}
