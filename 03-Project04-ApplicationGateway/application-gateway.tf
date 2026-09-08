# Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "web_ag_publicip" {
  name                = "${local.resource_group_prefix}-web-ag-publicip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
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


# Azure Application Gateway - Standard
resource "azurerm_application_gateway" "web_ag" {
  name                = "${local.resource_group_prefix}-web-ag"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  # START: --------------------------------------- #
  # SKU: Standard_v2 (New Version )
  sku {
    name     = "Basic"
    tier     = "Basic"
    capacity = 2
  }
  # autoscale_configuration {
  #   min_capacity = 0
  #   max_capacity = 10
  # }
  # END: --------------------------------------- #

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agsubnet.id
  }

  # Frontend Configs
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.web_ag_publicip.id
  }

  # Listener: HTTP 80
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  # App1 Configs
  backend_address_pool {
    name = local.backend_address_pool_name_app1
  }
  backend_http_settings {
    name                  = local.http_setting_name_app1
    cookie_based_affinity = "Disabled"
    # path                  = "/app1/"
    port            = 80
    protocol        = "Http"
    request_timeout = 60
    probe_name      = local.probe_name_app1
  }
  probe {
    name                = local.probe_name_app1
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/app1/status.html"
    match { # Optional
      body        = "App1"
      status_code = ["200"]
    }
  }

  # Rule-1
  request_routing_rule {
    name                       = local.request_routing_rule1_name
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name_app1
    backend_http_settings_name = local.http_setting_name_app1
  }
}
