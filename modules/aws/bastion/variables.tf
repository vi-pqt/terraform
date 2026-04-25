variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  description = "Private-app subnet ID for the bastion host"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs (use app SG so Aurora trusts it)"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "User data script for the bastion instance"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    dnf install -y mariadb105
  EOF
}
