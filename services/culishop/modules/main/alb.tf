# ============================================================
# Application Load Balancer (~$16/mo when enabled)
# Routes: / → reactfrontend, /api/* → apiservice
# Toggle: var.enable_alb
# ============================================================

module "alb" {
  source = "../../../../modules/aws/alb"
  count  = var.enable_alb ? 1 : 0

  project     = var.project
  environment = var.environment

  vpc_id            = local.vpc_id
  subnet_ids        = local.public_subnets
  security_group_id = local.alb_sg_id

  default_target = "reactfrontend"

  target_groups = {
    reactfrontend = {
      port                 = 80
      health_check_path    = "/healthz"
      health_check_matcher = "200"
      path_patterns        = []
      priority             = 0
    }
    apiservice = {
      port                 = 8090
      health_check_path    = "/healthz"
      health_check_matcher = "200"
      path_patterns        = ["/api/*"]
      priority             = 100
    }
  }
}
