# Account & Region
output "account_id" { value = local.account_id }
output "region" { value = local.region }

# VPC
output "vpc_id" { value = local.vpc_id }
output "vpc_cidr" { value = local.vpc_cidr_block }

# Subnets
output "public_subnets" { value = local.public_subnets }
output "private_subnets" { value = local.private_subnets }
output "data_subnets" { value = local.data_subnets }
output "database_subnet_group_name" { value = local.database_subnet_group_name }

# Security Groups
output "alb_sg" { value = local.alb_sg }
output "private_sg" { value = local.private_sg }
output "data_sg" { value = local.data_sg }

# ECR
output "ecr_registry" { value = local.ecr_registry }
