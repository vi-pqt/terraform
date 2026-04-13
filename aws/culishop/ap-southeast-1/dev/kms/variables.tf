variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "culishop"
}

variable "environment" {
  description = "Environment name (lab, dev, stg, prd)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}
