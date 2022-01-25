variable "basename" {
  type = string
  default = "Signature-Connection"
}

variable "env_name" {
  type = string
  default = "prod"
}
variable "default_tags" {
  type = map(string)
  default = {
    "Billing Unit"   = "",
    "Company"        = "Signature",
    "Environment"    = "Prod",
    "Operation Team" = "Infrastructure",
    "Region"         = "EastUS"
  }
}