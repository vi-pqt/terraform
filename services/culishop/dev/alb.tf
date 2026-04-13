#######################
# ALB
#######################
module "alb" {
  source = "../../../../modules/aws/alb"

  project_name = var.project_name
  stage        = var.stage
  vpc_id       = module.vpc.vpc_id

  load_balancer_type = var.load_balancer_type
  alb_sg_id          = module.vpc.alb_sg
  public_subnets     = module.vpc.public_subnets
  target_groups      = var.target_groups
  container_ports    = var.container_ports
  short_names        = var.short_names

  enable_deletion_protection = false
  is_enable_alb              = false # change to "true" if you want to create ALB
}
