provider "aws" {
  region = "ap-southeast-1"

  assume_role {
    role_arn     = "arn:aws:iam::660880135138:role/terraform-infra-deploy"
    session_name = "terraform-infra-deploy"
  }
}
