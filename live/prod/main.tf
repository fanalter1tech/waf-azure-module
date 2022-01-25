terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "d41310d2-3a24-4e23-b243-67da13e08c0b"
}

data "azurerm_resource_group" "this" {
  name = "Connection-WAF"
}

locals {
  resource_group_name            = "${data.azurerm_resource_group.this.name}"
  resource_group_location        = "${data.azurerm_resource_group.this.location}"
  basename                       = var.basename
  environment                    = var.env_name
  backend_address_pool_name      = "beap-${var.basename}-${var.env_name}-001"
  frontend_port_name             = "feport-${var.basename}-${var.env_name}-001"
  frontend_ip_configuration_name = "feip-${var.basename}-${var.env_name}-001"
  app_gw_ip_configuration_name  = "appgw-ipconf-${var.basename}-${var.env_name}-001"
  http_setting_name              = "be-htst-${var.basename}-${var.env_name}-001"
  listener_name                  = "httplstn-${var.basename}-${var.env_name}-001"
  request_routing_rule_name      = "rqrt-${var.basename}-${var.env_name}-001"
  redirect_configuration_name    = "rdrcfg-${var.basename}-${var.env_name}-001"
}

resource "azurerm_public_ip" this{
  name                = "pip-${local.basename}-${local.environment}-001"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  allocation_method   = "Dynamic"

  tags = merge(var.default_tags, {
    "Application"    = "Public IP",
    "description"    = "Public IP Address"
  })
}

module "vnet" {
  source = "../../module/vnet"

  name                    = "vnet-${local.basename}-${local.environment}-001"
  address_space          = ["10.254.0.0/16"]
  resource_group_location = local.resource_group_location
  resource_group_name     = local.resource_group_name
  

  tags = merge(var.default_tags, {
    "Application"    = "Vnet",
    "description"    = "Virtual Network"
    })

}

module "subnet" {
  source = "../../module/subnet"

  resource_group_name     = local.resource_group_name
  virtual_network_name    = "${module.vnet.name}"
}

module "waf-policy" {
  source = "../../module/waf-policy"

  name = "waf-policy-${local.basename}-${local.environment}-001"
  resource_group_location        = local.resource_group_location
  resource_group_name            = local.resource_group_name

  tags = merge(var.default_tags, {
    "Application"    = "WAF Policy",
    "description"    = "WAF policy associated with app gateway"
  })
}
module "app-gw" {
  source = "../../module/app-gw"

  name                           = "app-gw-${local.basename}-${local.environment}-001"
  resource_group_location        = local.resource_group_location
  resource_group_name            = local.resource_group_name
  app_gw_ip_configuration_name   = local.app_gw_ip_configuration_name
  subnet_id                      = "${module.subnet.frontend-id}"
  frontend_port_name             = local.frontend_port_name
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  public_ip_address_id           = azurerm_public_ip.this.id
  backend_address_pool_name      = local.backend_address_pool_name
  http_setting_name              = local.http_setting_name
  listener_name                  = local.listener_name
  request_routing_rule_name      = local.request_routing_rule_name
  firewall_policy_id             = "${module.waf-policy.id}"
  
  tags = merge(var.default_tags, {
    "Application"    = "Application Gateway",
    "description"    = "Application Gateway with WAF enabled"
  })
}
