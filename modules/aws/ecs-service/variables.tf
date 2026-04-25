variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  description = "Name of the microservice"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "image" {
  description = "Docker image URI (ECR URL:tag)"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "cpu" {
  description = "Task CPU units (256, 512, 1024, etc.)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of task instances"
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Map of environment variables"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnet IDs for the tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the tasks"
  type        = list(string)
}

variable "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "service_connect_enabled" {
  description = "Enable Service Connect"
  type        = bool
  default     = true
}

variable "service_connect_role" {
  description = "Service Connect role: 'client' (external), 'client_server' (internal)"
  type        = string
  default     = "client_server"
  validation {
    condition     = contains(["client", "client_server"], var.service_connect_role)
    error_message = "Must be 'client' or 'client_server'"
  }
}

variable "namespace_arn" {
  description = "Service Connect namespace ARN"
  type        = string
}

variable "namespace_name" {
  description = "Service Connect namespace DNS name (e.g. culishop.local)"
  type        = string
  default     = "culishop.local"
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "health_check_command" {
  description = "Container health check command (optional)"
  type        = list(string)
  default     = null
}

variable "load_balancer" {
  description = "Optional load balancer configuration"
  type = object({
    target_group_arn = string
    container_port   = number
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
