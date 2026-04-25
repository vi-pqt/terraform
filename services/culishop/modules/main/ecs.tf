module "ecs_cluster" {
  source = "../../../../modules/aws/ecs-cluster"

  project        = var.project
  environment    = var.environment
  namespace_name = "culishop.local"
}

# ============================================================
# Service Connect addresses — DRY
# ============================================================
locals {
  sc = {
    product  = "productcatalogservice.culishop.local:3550"
    cart     = "cartservicev2.culishop.local:7070"
    currency = "currencyservice.culishop.local:7000"
    shipping = "shippingservice.culishop.local:50051"
    checkout = "checkoutservice.culishop.local:5050"
    payment  = "paymentservice.culishop.local:50051"
    email    = "emailservice.culishop.local:8080"
    ad       = "adservice.culishop.local:9555"
    rec      = "recommendationservice.culishop.local:8080"
    mysql    = "mysql.culishop.local:3306"
    redis    = "redis.culishop.local:6379"
  }

  # Data service endpoints — conditional on managed vs ECS
  # When Aurora enabled: use Aurora endpoint instead of ECS MySQL Service Connect
  db_addr = var.enable_aurora ? "${module.aurora[0].cluster_endpoint}:3306" : local.sc.mysql
  db_user = var.enable_aurora ? module.aurora[0].master_username : "culishop"
  db_pass = var.enable_aurora ? var.aurora_master_password : "culishop"
  db_name = var.enable_aurora ? module.aurora[0].database_name : "culishop"

  # When ElastiCache enabled: use Valkey endpoint instead of ECS Redis
  cache_addr = var.enable_elasticache ? "${module.elasticache[0].primary_endpoint_address}:6379" : local.sc.redis

  # Shared module args for all services
  common = {
    cluster_id              = module.ecs_cluster.cluster_id
    subnet_ids              = local.private_app_subnets
    security_group_ids      = [local.app_sg_id]
    task_execution_role_arn = module.iam.task_execution_role_arn
    task_role_arn           = module.iam.task_role_arn
    namespace_arn           = module.ecs_cluster.namespace_arn
    namespace_name          = module.ecs_cluster.namespace_name
  }
}

# ============================================================
# External services (Service Connect role = client)
# ============================================================

module "apiservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "apiservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["apiservice"]}:latest"

  container_port = 8090
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client"

  load_balancer = var.enable_alb ? {
    target_group_arn = module.alb[0].target_group_arns["apiservice"]
    container_port   = 8090
  } : null

  environment_variables = {
    PORT                         = "8090"
    PRODUCT_CATALOG_SERVICE_ADDR = local.sc.product
    CART_SERVICE_ADDR            = local.sc.cart
    CURRENCY_SERVICE_ADDR        = local.sc.currency
    SHIPPING_SERVICE_ADDR        = local.sc.shipping
    CHECKOUT_SERVICE_ADDR        = local.sc.checkout
    AD_SERVICE_ADDR              = local.sc.ad
    RECOMMENDATION_SERVICE_ADDR  = local.sc.rec
    ALLOWED_ORIGINS              = "*"
  }

  depends_on = [module.mysql, module.redis]
}

module "reactfrontend" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "reactfrontend"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["reactfrontend"]}:latest"

  container_port = 80
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client"

  load_balancer = var.enable_alb ? {
    target_group_arn = module.alb[0].target_group_arns["reactfrontend"]
    container_port   = 80
  } : null

  depends_on = [module.apiservice]
}

# NOTE: "frontend" (Go SSR) removed — using "reactfrontend" (React SPA) instead.
# Both serve the same app; reactfrontend is the modern replacement.

# ============================================================
# Internal services (Service Connect role = client_server)
# ============================================================

module "productcatalogservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "productcatalogservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["productcatalogservice"]}:latest"

  container_port = 3550
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT           = "3550"
    MYSQL_ADDR     = local.db_addr
    MYSQL_USER     = local.db_user
    MYSQL_PASSWORD = local.db_pass
    MYSQL_DATABASE = local.db_name
  }

  depends_on = [module.mysql, module.aurora]
}

module "cartservicev2" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "cartservicev2"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["cartservicev2"]}:latest"

  container_port = 7070
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT           = "7070"
    REDIS_ADDR     = local.cache_addr
    MYSQL_ADDR     = local.db_addr
    MYSQL_USER     = local.db_user
    MYSQL_PASSWORD = local.db_pass
    MYSQL_DATABASE = local.db_name
  }

  depends_on = [module.mysql, module.redis, module.aurora, module.elasticache]
}

module "checkoutservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "checkoutservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["checkoutservice"]}:latest"

  container_port = 5050
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = merge(
    {
      PORT                         = "5050"
      CART_SERVICE_ADDR            = local.sc.cart
      PRODUCT_CATALOG_SERVICE_ADDR = local.sc.product
      CURRENCY_SERVICE_ADDR        = local.sc.currency
      SHIPPING_SERVICE_ADDR        = local.sc.shipping
      PAYMENT_SERVICE_ADDR         = local.sc.payment
      EMAIL_SERVICE_ADDR           = local.sc.email
      MYSQL_ADDR                   = local.db_addr
      MYSQL_USER                   = local.db_user
      MYSQL_PASSWORD               = local.db_pass
      MYSQL_DATABASE               = local.db_name
    },
    var.enable_messaging ? {
      ENABLE_SNS_PUBLISH    = "1"
      SNS_ORDER_TOPIC_ARN   = data.aws_sns_topic.order_events[0].arn
      SQS_PAYMENT_QUEUE_URL = data.aws_sqs_queue.payments[0].url
      AWS_REGION            = var.region
    } : {}
  )

  depends_on = [module.mysql, module.aurora]
}

module "currencyservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "currencyservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["currencyservice"]}:latest"

  container_port = 7000
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT             = "7000"
    DISABLE_PROFILER = "1"
  }
}

module "shippingservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "shippingservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["shippingservice"]}:latest"

  container_port = 50051
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT = "50051"
  }
}

module "paymentservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "paymentservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["paymentservice"]}:latest"

  container_port = 50051
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT             = "50051"
    DISABLE_PROFILER = "1"
  }
}

module "emailservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "emailservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["emailservice"]}:latest"

  container_port = 8080
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT = "8080"
  }
}

module "recommendationservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "recommendationservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["recommendationservice"]}:latest"

  container_port = 8080
  cpu            = 256
  memory         = 512
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT                         = "8080"
    PRODUCT_CATALOG_SERVICE_ADDR = local.sc.product
  }

  depends_on = [module.productcatalogservice]
}

module "adservice" {
  source = "../../../../modules/aws/ecs-service"

  project      = var.project
  environment  = var.environment
  service_name = "adservice"

  cluster_id = local.common.cluster_id
  image      = "${module.ecr.repository_urls["adservice"]}:latest"

  container_port = 9555
  desired_count  = var.desired_count

  subnet_ids              = local.common.subnet_ids
  security_group_ids      = local.common.security_group_ids
  task_execution_role_arn = local.common.task_execution_role_arn
  task_role_arn           = local.common.task_role_arn
  namespace_arn           = local.common.namespace_arn
  namespace_name          = local.common.namespace_name
  service_connect_role    = "client_server"

  environment_variables = {
    PORT = "9555"
  }
}
