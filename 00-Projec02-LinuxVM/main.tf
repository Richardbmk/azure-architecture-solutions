# Azure Resource Group (Helps file to use the existing resource group)
# resource "azurerm_resource_group" "rg" {
#   name     = "${local.resource_group_prefix}-${var.resource_group_name}-${random_string.default.id}"
#   location = var.resource_group_location
#   tags     = local.common_tags
# }

# Virtual Network, Subnets and Subnet NSG's

## Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.resource_group_prefix}-${var.vnet_name}"
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.common_tags
}

