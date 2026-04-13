provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::660880135138:role/terraform-infra-deploy"
    session_name = "terraform-apply-session"
  }
}
