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

# Create WebTier Subnet
resource "azurerm_subnet" "websubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.web_subnet_name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.web_subnet_address
}

# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "${azurerm_subnet.websubnet.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

## NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_nsg_rule_inbound" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.web_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
}

# Create AppTier Subnet
resource "azurerm_subnet" "appsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.app_subnet_name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.app_subnet_address
}

# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "${azurerm_subnet.appsubnet.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

## NSG Inbound Rule for AppTier Subnets
resource "azurerm_network_security_rule" "app_nsg_rule_inbound" {
  for_each                    = local.app_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.app_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
}


# Create DBTier Subnet
resource "azurerm_subnet" "dbsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.db_subnet_name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.db_subnet_address
}

# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "db_subnet_nsg" {
  name                = "${azurerm_subnet.dbsubnet.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

## NSG Inbound Rule for DBTier Subnets
resource "azurerm_network_security_rule" "db_nsg_rule_inbound" {
  for_each                    = local.db_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.db_subnet_nsg.name
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.db_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.dbsubnet.id
  network_security_group_id = azurerm_network_security_group.db_subnet_nsg.id
}

# Create Bastion / Management Subnet
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.bastion_subnet_name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.bastion_subnet_address
}

# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "bastion_subnet_nsg" {
  name                = "${azurerm_subnet.bastionsubnet.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}



## NSG Inbound Rule for Bastion / Management Subnets
resource "azurerm_network_security_rule" "bastion_nsg_rule_inbound" {
  for_each                    = local.bastion_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.bastion_subnet_nsg.name
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.bastion_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.bastionsubnet.id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_nsg.id
}


