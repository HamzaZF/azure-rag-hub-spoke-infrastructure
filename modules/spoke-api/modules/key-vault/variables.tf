variable "naming_company" {
    description = "The company name."
    type        = string
}

variable "naming_product" {
    description = "The product name."
    type        = string
}

variable "naming_environment" {
    description = "The environment name."
    type        = string
}

variable "naming_region" {
    description = "The region name."
    type        = string
}

variable "spoke_api_key_vault_resource_group_name" {
    description = "The resource group name for the key vault."
    type        = string
}

variable "spoke_api_key_vault_location" {
    description = "The location for the key vault."
    type        = string
}

variable "spoke_api_key_vault_sku_name" {
    description = "The SKU name for the key vault."
    type        = string
}

variable "spoke_api_subnet_wa_id" {
    description = "The ID of the subnet for the web app."
    type        = string
}

variable "spoke_api_key_vault_random_suffix_length" {
    description = "The length of the random suffix for the key vault."
    type        = number
}

variable "spoke_api_key_vault_random_suffix_special" {
    description = "The special characters for the key vault random suffix."
    type        = string
}

variable "spoke_api_key_vault_random_suffix_upper" {
    description = "The uppercase characters for the key vault random suffix."
    type        = string
}

variable "spoke_api_ag_ssl_certificate_path" {
    description = "The path to the SSL certificate."
    type        = string
}

variable "spoke_api_ag_ssl_certificate_password" {
    description = "The password for the SSL certificate."
    type        = string
}