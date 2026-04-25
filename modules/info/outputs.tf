# Account & Region
output "account_id" { value = local.account_id }
output "region"     { value = local.region }

# VPC
output "vpc_id"     { value = local.vpc_id }
output "vpc_cidr"   { value = local.vpc_cidr }

# Subnets
output "public_subnet_ids"      { value = local.public_subnet_ids }
output "private_app_subnet_ids" { value = local.private_app_subnet_ids }
output "private_data_subnet_ids" { value = local.private_data_subnet_ids }
output "database_subnet_group_name" { value = local.database_subnet_group_name }

# Security Groups
output "alb_security_group_id"  { value = local.alb_security_group_id }
output "app_security_group_id"  { value = local.app_security_group_id }
output "data_security_group_id" { value = local.data_security_group_id }

# ECR
output "ecr_registry" { value = local.ecr_registry }
