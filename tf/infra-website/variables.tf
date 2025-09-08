variable "default_tags" {
  default = {
    "ManagedBy" = "Terraform"
    "Project"   = "isititar.com"
  }
  description = "Key-value map of default tags to add to resources"
  type        = map(string)
}

variable "domain" {
  description = "Apex domain for the website"
  type        = string
  default     = "isititar.com"
}

variable "atproto_did" {
  description = "DID for atproto integration"
  type        = string
  default     = "did=did:plc:mkfxmzs6gyhy2lfbml3ls53h"
}
