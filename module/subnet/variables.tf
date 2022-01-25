variable "virtual_network_name" {}

variable "resource_group_name" {}

variable "subnets" {
  type = map
  default     = {
    "frontend" = {
        name                 = "frontend"
        address_prefixes     = ["10.254.0.0/24"]
    },
    "backend" = {
        name                 = "backend"
        address_prefixes     = ["10.254.2.0/24"]
    }
  }
}