variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "data_subnets" {
  description = "List of data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "stage" {
  description = "Stage of the environment"
  type        = string
}

variable "az" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1a", "1b", "1c"]
}

variable "is_single_nat_gw" {
  description = "Single NAT Gateway"
  type        = bool
  default     = false
}
