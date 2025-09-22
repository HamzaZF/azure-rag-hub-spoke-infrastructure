module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

resource "azurerm_cognitive_account" "kelix-openai" {
  name                  = "${module.naming.cognitive_account.name}-${random_string.open_ai_suffix.result}"
  location              = var.hub_openai_location
  resource_group_name   = var.hub_openai_resource_group_name
  kind                  = "OpenAI"
  sku_name              = var.hub_openai_sku_name
  custom_subdomain_name = var.hub_openai_custom_subdomain_name
  public_network_access_enabled = false
  outbound_network_access_restricted = true
}

resource "random_string" "open_ai_suffix" {
  length  = var.hub_openai_random_suffix_length
  special = var.hub_openai_random_suffix_special
  upper   = var.hub_openai_random_suffix_upper
}

# GPT-4.1 Mini for chat/conversation
resource "azurerm_cognitive_deployment" "gpt-41-mini" {
  name                 = "gpt-4.1-mini"
  cognitive_account_id = azurerm_cognitive_account.kelix-openai.id

  model {
    format  = "OpenAI"
    name    = var.hub_openai_gpt4_1_mini_model_name
    //version = var.hub_openai_gpt4_1_mini_model_version
  }

  sku {
    name = var.hub_openai_gpt4_1_mini_sku_name
    //tier = var.hub_openai_gpt4_1_mini_sku_tier
    //size = var.hub_openai_gpt4_1_mini_sku_size
    capacity = var.hub_openai_gpt4_1_mini_capacity
  }
}