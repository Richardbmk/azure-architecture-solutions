# Create Public IP Address for Azure Load Balancer
resource "azurerm_public_ip" "web_ag_publicip" {
  name                = "${local.resource_group_prefix}-web-ag-publicip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.resource_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Dedicated Public IP for NAT Gateway outbound traffic (must be separate from the LB's public IP)
resource "azurerm_public_ip" "web_natgw_publicip" {
  name                = "${local.resource_group_prefix}-natgw-publicip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.resource_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# NAT Gateway providing outbound internet access for the web subnet
resource "azurerm_nat_gateway" "web_natgw" {
  name                    = "${local.resource_group_prefix}-web-natgw"
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = var.resource_location
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
  depends_on = [azurerm_storage_blob.static_container_blob]

  name                = "${local.resource_group_prefix}-web-ag"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.resource_location
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

  # Frontend Port  - HTTP Port 80
  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  # Frontend Port  - HTTP Port 443
  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  # Frontend IP Configuration
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.web_ag_publicip.id
  }

  # App1 Configs
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

  # HTTP Listener - Port 80
  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
  }
  # HTTP Routing Rule - HTTP to HTTPS Redirect
  request_routing_rule {
    name                        = local.request_routing_rule_name_http
    rule_type                   = "Basic"
    priority                    = 100
    http_listener_name          = local.listener_name_http
    redirect_configuration_name = local.redirect_configuration_name
  }
  # Redirect Config for HTTP to HTTPS Redirect  
  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name_https
    include_path         = true
    include_query_string = true
  }

  # # SSL Certificate Block
  # ssl_certificate {
  #   name     = local.ssl_certificate_name
  #   password = var.password_httpd_ssl_pfx
  #   data     = filebase64("/etc/ssl/httpd.pfx")
  # }

  ssl_certificate {
    name                = local.ssl_certificate_name_keyvault
    key_vault_secret_id = azurerm_key_vault_certificate.my_cert_1.secret_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appag_umid.id]
  }

  # HTTPS Listener - Port 443  
  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_https
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name_keyvault
    custom_error_configuration {
      custom_error_page_url = "${azurerm_storage_account.storage_account.primary_web_endpoint}502.html"
      status_code           = "HttpStatus502"
    }
    custom_error_configuration {
      custom_error_page_url = "${azurerm_storage_account.storage_account.primary_web_endpoint}403.html"
      status_code           = "HttpStatus403"
    }
  }

  # HTTPS Routing Rule - Port 443
  request_routing_rule {
    name                       = local.request_routing_rule_name_https
    rule_type                  = "Basic"
    priority                   = 200
    http_listener_name         = local.listener_name_https
    backend_address_pool_name  = local.backend_address_pool_name_app1
    backend_http_settings_name = local.http_setting_name_app1
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


# Add app1 Record Set in DNS Zone
resource "azurerm_dns_a_record" "dns_record_app1" {
  depends_on          = [azurerm_application_gateway.web_ag]
  name                = "@"
  zone_name           = azurerm_dns_zone.public_dns_zone.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.web_ag_publicip.id
}
