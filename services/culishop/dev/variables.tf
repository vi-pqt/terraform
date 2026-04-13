variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "stage" {
  description = "Stage"
  type        = string
}

# VPC variables
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

# ECS Service variables
variable "short_names" {
  description = "List of short names"
  type        = list(string)
  default     = []
}

variable "service_names" {
  description = "List of service names"
  type        = list(string)
  default     = []
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "container_ports" {
  description = "Map of container ports"
  type        = map(number)
  default     = {}
}

variable "state_bucket_name" {
  description = "State bucket name"
  type        = string
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"

  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be application or network"
  }
}

variable "target_groups" {
  description = "Map of target groups"
  type = map(object({
    port                 = number
    health_check_path    = string
    priority             = number
    path_patterns        = list(string)
    health_check_matcher = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
