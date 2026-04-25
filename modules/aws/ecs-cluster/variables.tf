variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "namespace_name" {
  description = "Service Connect namespace name"
  type        = string
  default     = "culishop.local"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
