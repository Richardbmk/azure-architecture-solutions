# Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "web_lbpublicip" {
  name                = "${local.resource_group_prefix}-lbpublicip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # "domain_name_label" required for Azure Traffic Manager
  domain_name_label = "${local.resource_group_prefix}"
  tags                = local.common_tags
}

# Dedicated Public IP for NAT Gateway outbound traffic (must be separate from the LB's public IP)
resource "azurerm_public_ip" "web_natgw_publicip" {
  name                = "${local.resource_group_prefix}-natgw-publicip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# NAT Gateway providing outbound internet access for the web subnet
resource "azurerm_nat_gateway" "web_natgw" {
  name                    = "${local.resource_group_prefix}-web-natgw"
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = local.common_tags
}

# Attach the public IP to the NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "web_natgw_publicip_association" {
  nat_gateway_id       = azurerm_nat_gateway.web_natgw.id
  public_ip_address_id = azurerm_public_ip.web_natgw_publicip.id
}

# Associate the NAT Gateway with the web subnet
resource "azurerm_subnet_nat_gateway_association" "web_subnet_natgw_association" {
  subnet_id      = azurerm_subnet.websubnet.id
  nat_gateway_id = azurerm_nat_gateway.web_natgw.id
}

# Create Azure Standard Load Balancer
resource "azurerm_lb" "web_lb" {
  name                = "${local.resource_group_prefix}-web-lb"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "web-lb-publicip-1"
    public_ip_address_id = azurerm_public_ip.web_lbpublicip.id
  }
}

# Create LB Backend Pool
resource "azurerm_lb_backend_address_pool" "web_lb_backend_address_pool" {
  name            = "web-backend"
  loadbalancer_id = azurerm_lb.web_lb.id
}

# Create LB Probe
resource "azurerm_lb_probe" "web_lb_probe" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.web_lb.id
}

# Create LB Rule
resource "azurerm_lb_rule" "web_lb_rule_app1" {
  name                           = "web-app1-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.web_lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
  loadbalancer_id                = azurerm_lb.web_lb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
}