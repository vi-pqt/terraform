variable "project_name" {
  description = "Project name"
  type        = string
}

variable "stage" {
  description = "Stage of the environment"
  type        = string
}

variable "short_names" {
  description = "List of short names for ECR repositories"
  type        = list(string)
  default     = []
}
