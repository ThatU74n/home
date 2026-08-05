variable "user_id" {
  type     = string
  nullable = false
}

variable "user_token_name" {
  type     = string
  nullable = true
  default  = null
}

variable "acl" {
  type = list(
    object({
      path    = string
      role_id = string
    })
  )
  nullable = false
  default  = []
}
