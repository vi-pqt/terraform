variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID for target groups"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "target_groups" {
  description = "Map of target group configurations"
  type = map(object({
    port                 = number
    health_check_path    = string
    health_check_matcher = string
    path_patterns        = list(string)
    priority             = number
  }))
}

variable "default_target" {
  description = "Key in target_groups to use as the default listener action"
  type        = string
}
