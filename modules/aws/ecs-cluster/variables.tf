variable "project_name" {
  description = "Project name"
  type        = string
}

variable "stage" {
  description = "Stage of the environment"
  type        = string
}

variable "namespace" {
  description = "Service Connect namespace"
  type        = string
  default     = "culishop.local"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
