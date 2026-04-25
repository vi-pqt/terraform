variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for sops encryption"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
