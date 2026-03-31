module "ecr" {
  source = "../../../../modules/aws/ecr"

  short_names  = var.short_names
  project_name = var.project_name
  stage        = var.stage
}
