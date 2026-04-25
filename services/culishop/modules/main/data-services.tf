# Custom MySQL with baked-in schema and seed data
# Data persistence: NONE — Fargate ephemeral storage only
# Disable when using Aurora MySQL (Session 09)
module "mysql" {
  source = "../../../../modules/aws/ecs-service"
  count  = var.enable_mysql_ecs ? 1 : 0

  project     = var.project
  environment = var.environment

  service_name = "mysql"
  cluster_id   = module.ecs_cluster.cluster_id
  image        = "${module.ecr.repository_urls["mysql"]}:latest"

  container_port = 3306
  desired_count  = var.desired_count

  subnet_ids         = local.private_app_subnets
  security_group_ids = [local.app_sg_id]

  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn

  namespace_arn        = module.ecs_cluster.namespace_arn
  namespace_name       = module.ecs_cluster.namespace_name
  service_connect_role = "client_server"

  environment_variables = {
    MYSQL_ROOT_PASSWORD = "culishop"
    MYSQL_USER          = "culishop"
    MYSQL_PASSWORD      = "culishop"
    MYSQL_DATABASE      = "culishop"
  }

  health_check_command = ["CMD-SHELL", "mysqladmin ping -h localhost -uculishop -pculishop || exit 1"]
}

# Redis — official image, no custom build needed
# Disable when using ElastiCache Valkey (Session 10)
module "redis" {
  source = "../../../../modules/aws/ecs-service"
  count  = var.enable_redis_ecs ? 1 : 0

  project     = var.project
  environment = var.environment

  service_name = "redis"
  cluster_id   = module.ecs_cluster.cluster_id
  image        = "redis:7-alpine"

  container_port = 6379
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids         = local.private_app_subnets
  security_group_ids = [local.app_sg_id]

  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn

  namespace_arn        = module.ecs_cluster.namespace_arn
  namespace_name       = module.ecs_cluster.namespace_name
  service_connect_role = "client_server"

  health_check_command = ["CMD-SHELL", "redis-cli ping || exit 1"]
}

# ============================================================
# Aurora MySQL (Session 09 / Session 14)
# Replaces MySQL ECS task with managed database
# Toggle: var.enable_aurora
# ============================================================

module "aurora" {
  source = "../../../../modules/aws/aurora"
  count  = var.enable_aurora ? 1 : 0

  project     = var.project
  environment = var.environment

  db_subnet_group_name = local.database_subnet_group
  security_group_id    = local.data_sg_id

  master_password     = var.aurora_master_password
  instance_class      = var.aurora_instance_class
  deletion_protection = var.aurora_deletion_protection
  skip_final_snapshot = var.aurora_skip_final_snapshot
}

# ============================================================
# ElastiCache Redis (Session 10 / Session 14)
# Replaces Redis ECS task with managed cache
# Toggle: var.enable_elasticache
# ============================================================

module "elasticache" {
  source = "../../../../modules/aws/elasticache"
  count  = var.enable_elasticache ? 1 : 0

  project     = var.project
  environment = var.environment

  subnet_ids        = local.private_data_subnets
  security_group_id = local.data_sg_id

  auth_token         = var.elasticache_auth_token
  node_type          = var.elasticache_node_type
  num_cache_clusters = var.elasticache_num_cache_clusters
}

