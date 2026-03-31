variable "is_deployment_circuit_breaker_enable" {
  type    = bool
  default = true
}

variable "is_deployment_circuit_breaker_rollback" {
  type    = bool
  default = true
}

variable "deployment_controller_type" {
  description = "The type of deployment controller to use for the service. Eg: ECS, CODE_DEPLOY, EXTERNAL"
  type        = string
  default     = "ECS"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "stage" {
  type        = string
  description = "The stage name"
}

variable "service_name" {
  type        = list(string)
  description = "The list of service names"
}

variable "ecs_cluster_id" {
  type        = string
  description = "The ID of the ECS cluster"
}

variable "desired_count" {
  type        = number
  description = "The desired count of tasks"
  default     = 1
}

variable "task_role_arn" {
  type        = string
  description = "The ARN of the task role"
}

variable "task_execution_role_arn" {
  type        = string
  description = "The ARN of the task execution role"
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnets"
}

variable "private_sg" {
  type        = list(string)
  description = "The list of private security groups"
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "container_port" {
  type = map(number)
  default = {
    "apiservice" = 80
  }
}

variable "ecr_url" {
  type        = list(string)
  description = "The URL of the ECR"
}
