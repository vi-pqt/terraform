variable "project_name" {
  description = "Project name"
  type        = string
}

variable "stage" {
  description = "Stage"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "data_sg" {
  description = "Data security group name"
  type        = string
}

variable "data_subnets" {
  description = "Data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "culishop"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "culishop_admin"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "aurora_engine" {
  description = "Aurora engine"
  type        = string
  default     = "aurora-mysql"
}

variable "aurora_engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.10.4"
}

variable "aurora_instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.t3.small"
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window UTC"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window UTC"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = true
}
