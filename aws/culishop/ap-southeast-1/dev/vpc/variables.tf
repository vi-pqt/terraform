variable "project_name" {
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

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "data_subnets" {
  description = "Data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "stage" {
  description = "Stage example: dev, qa, uat, prod"
  type        = string
}
