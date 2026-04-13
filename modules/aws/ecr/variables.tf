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

variable "force_delete" {
  description = "Force delete ECR repositories"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
