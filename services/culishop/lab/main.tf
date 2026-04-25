provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

module "main" {
  source = "../modules/main"

  project     = var.project
  environment = var.environment
  region      = var.region

  # Feature toggles
  enable_alb     = var.enable_alb
  enable_bastion = var.enable_bastion
  desired_count  = var.desired_count

  # Data services
  enable_mysql_ecs = var.enable_mysql_ecs
  enable_redis_ecs = var.enable_redis_ecs

  # Aurora
  enable_aurora              = var.enable_aurora
  aurora_master_password     = var.aurora_master_password
  aurora_instance_class      = var.aurora_instance_class
  aurora_deletion_protection = var.aurora_deletion_protection
  aurora_skip_final_snapshot = var.aurora_skip_final_snapshot

  # ElastiCache
  enable_elasticache             = var.enable_elasticache
  elasticache_auth_token         = var.elasticache_auth_token
  elasticache_node_type          = var.elasticache_node_type
  elasticache_num_cache_clusters = var.elasticache_num_cache_clusters

  # KMS
  kms_state_path = var.kms_state_path

  # Source
  culishop_source_path = var.culishop_source_path
  services             = var.services

  # Messaging
  enable_messaging        = var.enable_messaging
  enable_lambda_consumers = var.enable_lambda_consumers
  enable_sqs_triggers     = var.enable_sqs_triggers

  # GitHub Actions OIDC (Session 15)
  enable_github_oidc = var.enable_github_oidc
  github_org         = var.github_org
  github_repo        = var.github_repo
}
