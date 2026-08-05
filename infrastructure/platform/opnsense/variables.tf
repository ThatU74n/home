variable "opnsense_api_endpoint" {
  type     = string
  nullable = false
}

variable "opnsense_api_key" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "opnsense_api_secret" {
  type      = string
  nullable  = false
  sensitive = true
}
