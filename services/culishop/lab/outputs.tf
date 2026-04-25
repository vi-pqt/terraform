# ── Proxy all outputs from modules/main ──

output "caller_account_id" {
  value = module.main.caller_account_id
}

output "caller_user_arn" {
  value = module.main.caller_user_arn
}

output "caller_region" {
  value = module.main.caller_region
}

output "ecr_registry" {
  value = module.main.ecr_registry
}

output "ecr_repository_urls" {
  value = module.main.ecr_repository_urls
}

output "ecs_cluster_name" {
  value = module.main.ecs_cluster_name
}

output "ecs_cluster_arn" {
  value = module.main.ecs_cluster_arn
}

output "app_security_group_id" {
  value = module.main.app_security_group_id
}

output "alb_security_group_id" {
  value = module.main.alb_security_group_id
}

output "public_subnet_ids" {
  value = module.main.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.main.private_app_subnet_ids
}

output "vpc_id" {
  value = module.main.vpc_id
}

output "alb_dns_name" {
  value = module.main.alb_dns_name
}

output "alb_arn" {
  value = module.main.alb_arn
}

output "bastion_instance_id" {
  value = module.main.bastion_instance_id
}

output "bastion_private_ip" {
  value = module.main.bastion_private_ip
}

output "aurora_cluster_endpoint" {
  value     = module.main.aurora_cluster_endpoint
  sensitive = true
}

output "aurora_reader_endpoint" {
  value     = module.main.aurora_reader_endpoint
  sensitive = true
}

output "aurora_database_name" {
  value = module.main.aurora_database_name
}

output "elasticache_endpoint" {
  value     = module.main.elasticache_endpoint
  sensitive = true
}

output "elasticache_port" {
  value = module.main.elasticache_port
}

output "kms_sops_key_arn" {
  value = module.main.kms_sops_key_arn
}

output "lambda_consumer_names" {
  value = module.main.lambda_consumer_names
}

output "github_actions_role_arn" {
  description = "IAM role ARN — set as AWS_ROLE_ARN secret in GitHub repo"
  value       = module.main.github_actions_role_arn
}
