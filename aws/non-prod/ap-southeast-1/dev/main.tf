data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket  = var.state_bucket_name
    key     = "ecr/terraform.tfstate"
    region  = var.region
    profile = var.project_name
  }
}

#######################
# VPC
#######################
module "vpc" {
  source = "../../../../modules/aws/vpc"

  project_name = var.project_name
  stage        = var.stage

  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  data_subnets       = var.data_subnets
  availability_zones = var.availability_zones
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
}

#######################
# ECS Cluster
#######################
module "ecs-cluster" {
  source = "../../../../modules/aws/ecs-cluster"

  project_name = var.project_name
  stage        = var.stage
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
  ecr_url          = data.terraform_remote_state.ecr.outputs.ecr_repository_url
  assign_public_ip = false

  # List of service names
  service_name = var.service_name

  # Map of container ports
  container_port = var.container_port
}

