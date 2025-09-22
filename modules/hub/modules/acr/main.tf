module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

resource "azurerm_container_registry" "acr" {
  name                          = "${module.naming.container_registry.name}${random_string.acr_suffix.result}"
  resource_group_name           = var.hub_acr_resource_group_name
  location                      = var.hub_acr_location
  sku                           = var.hub_acr_sku
  admin_enabled                 = var.hub_acr_admin_enabled
  public_network_access_enabled = var.hub_acr_public_network_access_enabled
}

resource "random_string" "acr_suffix" {
  length  = var.hub_acr_random_suffix_length
  special = var.hub_acr_random_suffix_special
  upper   = var.hub_acr_random_suffix_upper
}