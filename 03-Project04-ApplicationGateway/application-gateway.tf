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


  # Listerner: HTTP Port 80 with app1.azure.ricardoboriba.net
  http_listener {
    name                           = local.listener_name_app1
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_names                     = ["app1.azure.${var.domain_name}"]
  }


  # Listerner: HTTP Port 80 with app2.azure.ricardoboriba.net 
  http_listener {
    name                           = local.listener_name_app2
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_names                     = ["app2.azure.${var.domain_name}"]
  }


  # App1 Backend Configs
  backend_address_pool {
    name = local.backend_address_pool_name_app1
  }
  backend_http_settings {
    name                  = local.http_setting_name_app1
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.probe_name_app1
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


  # App2 Backend Configs
  backend_address_pool {
    name = local.backend_address_pool_name_app2
  }
  backend_http_settings {
    name                  = local.http_setting_name_app2
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.probe_name_app2
  }
  probe {
    name                = local.probe_name_app2
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/app2/status.html"
    match { # Optional
      body        = "App2"
      status_code = ["200"]
    }
  }


  # Routing Rule - app1.azure.ricardoboriba.net
  request_routing_rule {
    name                       = local.request_routing_rule_name_app1
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.listener_name_app1
    backend_address_pool_name  = local.backend_address_pool_name_app1
    backend_http_settings_name = local.http_setting_name_app1
  }

  # Routing Rule - app2.azure.ricardoboriba.net
  request_routing_rule {
    name                       = local.request_routing_rule_name_app2
    rule_type                  = "Basic"
    priority                   = 200
    http_listener_name         = local.listener_name_app2
    backend_address_pool_name  = local.backend_address_pool_name_app2
    backend_http_settings_name = local.http_setting_name_app2
  }

}



# #################################
# Public DNS Zone Configuration - #
# #################################

# Create Azure Public DNS Zone
resource "azurerm_dns_zone" "public_dns_zone" {
  name                = "azure.${var.domain_name}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# AWS Route 53 Parent Zone Data Source
data "aws_route53_zone" "parent" {
  name         = "${var.domain_name}."
  private_zone = false
}

# AWS Route 53 Record for Azure Subdomain Delegation
resource "aws_route53_record" "azure_subdomain_delegation" {
  zone_id = data.aws_route53_zone.parent.zone_id

  name = "azure.${var.domain_name}"
  type = "NS"
  ttl  = 300

  records = azurerm_dns_zone.public_dns_zone.name_servers
}

# Add app2 Record Set in DNS Zone
resource "azurerm_dns_a_record" "dns_record_app2" {
  depends_on = [azurerm_application_gateway.web_ag]
  name                = "app2"
  zone_name           = azurerm_dns_zone.public_dns_zone.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.web_ag_publicip.id
}
# Add app1 Record Set in DNS Zone
resource "azurerm_dns_a_record" "dns_record_app1" {
  depends_on = [azurerm_application_gateway.web_ag]
  name                = "app1"
  zone_name           = azurerm_dns_zone.public_dns_zone.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.web_ag_publicip.id
}
