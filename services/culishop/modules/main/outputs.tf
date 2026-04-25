# ── Caller verification ──
output "caller_account_id" {
  description = "AWS Account ID — verify this is correct"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_user_arn" {
  description = "IAM identity applying — verify correct role/user"
  value       = data.aws_caller_identity.current.arn
}

output "caller_region" {
  description = "AWS Region — verify correct region"
  value       = data.aws_region.current.id
}

# ── ECR ──
output "ecr_registry" {
  description = "ECR registry URL"
  value       = local.ecr_registry
}

output "ecr_repository_urls" {
  description = "Map of service name to ECR repo URL"
  value       = module.ecr.repository_urls
}

# ── ECS ──
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs_cluster.cluster_arn
}

# ── Networking ──
output "app_security_group_id" {
  description = "App tier security group"
  value       = local.app_sg_id
}

output "alb_security_group_id" {
  description = "ALB security group"
  value       = local.alb_sg_id
}

output "public_subnet_ids" {
  description = "Public subnets (for ALB)"
  value       = local.public_subnets
}

output "private_app_subnet_ids" {
  description = "Private app subnets (where ECS tasks run)"
  value       = local.private_app_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

# ── ALB ──
output "alb_dns_name" {
  description = "ALB DNS name (access CuliShop here)"
  value       = var.enable_alb ? module.alb[0].alb_dns_name : null
}

output "alb_arn" {
  description = "ALB ARN"
  value       = var.enable_alb ? module.alb[0].alb_arn : null
}

# ── Bastion ──
output "bastion_instance_id" {
  description = "Bastion instance ID (connect: aws ssm start-session --target <id>)"
  value       = var.enable_bastion ? module.bastion[0].instance_id : null
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = var.enable_bastion ? module.bastion[0].private_ip : null
}

# ── Aurora MySQL ──
output "aurora_cluster_endpoint" {
  description = "Aurora writer endpoint"
  value       = var.enable_aurora ? module.aurora[0].cluster_endpoint : null
  sensitive   = true
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = var.enable_aurora ? module.aurora[0].reader_endpoint : null
  sensitive   = true
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = var.enable_aurora ? module.aurora[0].database_name : null
}

# ── ElastiCache ──
output "elasticache_endpoint" {
  description = "ElastiCache primary endpoint"
  value       = var.enable_elasticache ? module.elasticache[0].primary_endpoint_address : null
  sensitive   = true
}

output "elasticache_port" {
  description = "ElastiCache port"
  value       = var.enable_elasticache ? module.elasticache[0].port : null
}

# ── KMS ──
output "kms_sops_key_arn" {
  description = "KMS key ARN for sops encryption (from shared infra)"
  value       = var.kms_state_path != null ? data.terraform_remote_state.kms[0].outputs.kms_key_arn : null
}

# ── Messaging / Lambda ──
output "lambda_consumer_names" {
  description = "Lambda consumer function names"
  value       = local.lambda_consumers_enabled ? { for k, v in aws_lambda_function.consumer : k => v.function_name } : null
}

# ── GitHub Actions OIDC (Session 15) ──
output "github_actions_role_arn" {
  description = "IAM role ARN — set as AWS_ROLE_ARN secret in GitHub repo"
  value       = var.enable_github_oidc ? module.github_oidc_role.arn : null
}
