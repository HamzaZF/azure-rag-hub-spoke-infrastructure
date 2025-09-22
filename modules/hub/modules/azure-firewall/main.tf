# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Public IP for Azure Firewall
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "azure_firewall_pip" {
  name                = "${module.naming.public_ip.name}-firewall"
  resource_group_name = var.hub_azure_firewall_resource_group_name
  location            = var.hub_azure_firewall_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -----------------------------------------------------------------------------
# Azure Firewall
# -----------------------------------------------------------------------------
resource "azurerm_firewall" "azure_firewall" {
  name                = "AzureFirewallSubnet"
  resource_group_name = var.hub_azure_firewall_resource_group_name
  location            = var.hub_azure_firewall_location
  sku_tier            = var.hub_azure_firewall_sku_tier
  sku_name            = var.hub_azure_firewall_sku_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.hub_azure_firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.azure_firewall_pip.id
  }
}

resource "random_string" "storage_suffix" {
  length  = var.hub_azure_firewall_random_suffix_length
  special = var.hub_azure_firewall_random_suffix_special
  upper   = var.hub_azure_firewall_random_suffix_upper
}

// DO NAT routing

resource "azurerm_firewall_network_rule_collection" "azurerm_firewall_network_rule_collection" {
  name                = "Allow-Spoke-To-Spoke-Traffic"
  resource_group_name = var.hub_azure_firewall_resource_group_name
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "Allow-Spoke-API-to-Spoke-AI-Traffic"
    protocols = ["TCP"]
    source_addresses      = var.spoke_api_vnet_address_space
    destination_addresses = var.spoke_ai_vnet_address_space
    destination_ports     = ["*"]                  # any port
  }
}