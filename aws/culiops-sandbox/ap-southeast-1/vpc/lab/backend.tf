terraform {
  backend "s3" {
    bucket       = "culishop-terraform-state-lab"
    key          = "shared/vpc/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true

    assume_role = {
      role_arn     = "arn:aws:iam::660880135138:role/terraform-infra-deploy"
      session_name = "terraform-infra-deploy"
    }
  }
}
