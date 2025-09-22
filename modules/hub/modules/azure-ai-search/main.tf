module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

resource "azurerm_search_service" "search_service" {
  name                          = "${module.naming.search_service.name}-${random_string.search_suffix.result}"
  resource_group_name           = var.hub_ai_search_resource_group_name
  location                      = var.hub_ai_search_location
  sku                           = var.hub_ai_search_sku
  public_network_access_enabled = false
  hosting_mode                  = var.hub_ai_search_hosting_mode
  partition_count               = var.hub_ai_search_partition_count
  replica_count                 = var.hub_ai_search_replica_count
  semantic_search_sku           = var.hub_ai_search_semantic_search_sku
  local_authentication_enabled  = false
}

resource "random_string" "search_suffix" {
  length  = var.hub_ai_search_random_suffix_length
  special = var.hub_ai_search_random_suffix_special
  upper   = var.hub_ai_search_random_suffix_upper
}






