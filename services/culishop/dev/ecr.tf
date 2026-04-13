#######################
# ECR
#######################
module "ecr" {
  source = "../../../../modules/aws/ecr"

  short_names  = var.short_names
  project_name = var.project_name
  stage        = var.stage
  force_delete = false

  common_tags = var.common_tags
}
