variable "default_tags" {
  type = map(string)
  default = {
    Project = "isititar.com"
  }
}

variable "domain" {
  description = "Domain"
  type        = string
  default     = "isititar.com"
}
