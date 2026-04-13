locals {
  path_module = "../../../../modules/aws"
}

#######################
# IAM
#######################
module "iam" {
  source = "../../../../modules/aws/iam"

  project_name = var.project_name
  stage        = var.stage

  aws_account_id = var.aws_account_id
  region         = var.region

  common_tags = var.common_tags
}

#######################
# ECS Cluster
#######################
module "ecs-cluster" {
  source = "../../../../modules/aws/ecs-cluster"

  project_name = var.project_name
  stage        = var.stage

  common_tags = var.common_tags
}

module "ecs-service" {
  source = "../../../../modules/aws/ecs-service"

  project_name            = var.project_name
  stage                   = var.stage
  task_role_arn           = module.iam.ecs_task_role_arn
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn

  ecs_cluster_id   = module.ecs-cluster.ecs_cluster_id
  private_subnets  = module.vpc.private_subnets
  private_sg       = module.vpc.private_sg
  ecr_url          = module.ecr.ecr_repository_url
  assign_public_ip = false

  # List of service names
  service_names = var.service_names

  # Map of container ports
  container_ports = var.container_ports
}


