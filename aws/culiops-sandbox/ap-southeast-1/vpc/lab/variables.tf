variable "project" {
  description = "Project name used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (lab, dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_app_subnets" {
  description = "List of private application subnet CIDR blocks"
  type        = list(string)
}

variable "private_data_subnets" {
  description = "List of private data subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (disable to save ~$32/mo when not in use)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = true
}

