# ── Core ──
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (lab, dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

# ── Feature toggles ──
variable "enable_alb" {
  description = "Enable ALB (disable to save ~$16/mo when not in use)"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Enable bastion host for database access via SSM (~$0.012/hr)"
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Default desired task count for all ECS services (0 = no running tasks)"
  type        = number
  default     = 0
}

variable "enable_mysql_ecs" {
  description = "Enable MySQL ECS task (disable when using Aurora)"
  type        = bool
  default     = true
}

variable "enable_redis_ecs" {
  description = "Enable Redis ECS task (disable when using ElastiCache)"
  type        = bool
  default     = true
}

# ── Aurora MySQL ──
variable "enable_aurora" {
  description = "Enable Aurora MySQL (disable ECS MySQL first: enable_mysql_ecs = false)"
  type        = bool
  default     = false
}

variable "aurora_master_password" {
  description = "Aurora master password (>= 16 chars). Encrypt with sops for Git."
  type        = string
  sensitive   = true
  default     = null
}

variable "aurora_instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_deletion_protection" {
  description = "Enable deletion protection (false for lab, true for prod)"
  type        = bool
  default     = false
}

variable "aurora_skip_final_snapshot" {
  description = "Skip final snapshot on destroy (true for lab, false for prod)"
  type        = bool
  default     = true
}

# ── ElastiCache ──
variable "enable_elasticache" {
  description = "Enable ElastiCache Valkey (disable ECS Redis first: enable_redis_ecs = false)"
  type        = bool
  default     = false
}

variable "elasticache_auth_token" {
  description = "ElastiCache AUTH token (>= 16 chars). Encrypt with sops for Git."
  type        = string
  sensitive   = true
  default     = null
}

variable "elasticache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_num_cache_clusters" {
  description = "Number of cache clusters (1 for lab, 2+ for prod Multi-AZ)"
  type        = number
  default     = 1
}

# ── KMS ──
variable "kms_state_path" {
  description = "Path to KMS terraform state file (null = KMS not deployed yet)"
  type        = string
  default     = null
}

# ── CuliShop source ──
variable "culishop_source_path" {
  description = "Path to CuliShop application source code"
  type        = string
  default     = "/home/culiops/projects/culishop"
}

variable "services" {
  description = "List of CuliShop microservice names to deploy"
  type        = list(string)
  default = [
    "apiservice",
    "reactfrontend",
    "productcatalogservice",
    "cartservicev2",
    "checkoutservice",
    "currencyservice",
    "shippingservice",
    "paymentservice",
    "emailservice",
    "recommendationservice",
    "adservice",
  ]
}

# ── Messaging / Lambda (Session 11) ──
variable "enable_messaging" {
  description = "DEPRECATED: Use enable_lambda_consumers + enable_sqs_triggers instead."
  type        = bool
  default     = false
}

variable "enable_lambda_consumers" {
  description = "Create Lambda consumer functions + IAM role (no SQS dependency)"
  type        = bool
  default     = false
}

variable "enable_sqs_triggers" {
  description = "Wire Lambda consumers to SQS queues via event source mappings (queues must exist first)"
  type        = bool
  default     = false
}

# ── GitHub Actions OIDC (Session 15) ──
variable "enable_github_oidc" {
  description = "Enable GitHub Actions OIDC role for CI/CD ($0 — IAM is free)"
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub organization or user name"
  type        = string
  default     = "culiops"
}

variable "github_repo" {
  description = "GitHub repository name for OIDC trust policy"
  type        = string
  default     = "culishop"
}
