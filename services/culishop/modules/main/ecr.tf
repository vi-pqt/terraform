module "ecr" {
  source = "../../../../modules/aws/ecr"

  project          = var.project
  environment      = var.environment
  repository_names = concat(var.services, ["mysql"])
}
