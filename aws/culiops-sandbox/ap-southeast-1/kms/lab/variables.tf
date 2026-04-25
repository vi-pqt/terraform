variable "project" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "culishop"
}

variable "environment" {
  description = "Environment name (lab, dev, stg, prd)"
  type        = string
  default     = "lab"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}
