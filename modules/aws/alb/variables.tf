variable "project_name" {
  type        = string
  description = "Project name"
}

variable "stage" {
  type        = string
  description = "Stage name"
}

variable "is_enable_alb" {
  type        = bool
  description = "Enable or disable ALB"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"

  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be application or network"
  }
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"

  validation {
    condition     = length(var.public_subnets) >= 3
    error_message = "Public subnets must be at least 3"
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "container_ports" {
  type        = map(number)
  description = "Map of container ports"
}

variable "short_names" {
  type        = list(string)
  description = "List of short names"
}

variable "target_groups" {
  type = map(object({
    port                 = number
    health_check_path    = string
    priority             = number
    path_patterns        = list(string)
    health_check_matcher = string
  }))
  description = "Map of target groups"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
