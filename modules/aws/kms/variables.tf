variable "project_name" {
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

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
