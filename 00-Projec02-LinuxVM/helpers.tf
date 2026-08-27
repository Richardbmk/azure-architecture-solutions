# Random String Resource
resource "random_string" "default" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

data "azurerm_resource_group" "rg" {
  name = var.existing_resource_group_name
}


# Resource-3 (Optional): Create Network Security Group and Associate to Linux VM Network Interface
# Create Network Security Group (NSG)
resource "azurerm_network_security_group" "web_vmnic_nsg" {
  name                = "${azurerm_network_interface.web_linuxvm_nic.name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}


# NSG Inbound Rule for WebTier Subnets
resource "azurerm_network_security_rule" "web_vmnic_nsg_rule_inbound" {
  for_each                    = local.web_vmnic_inbound_ports_map
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
  network_security_group_name = azurerm_network_security_group.web_vmnic_nsg.name
}




