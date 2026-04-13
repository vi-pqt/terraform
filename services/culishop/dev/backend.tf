terraform {
  backend "s3" {
    bucket       = "culishop-tf-state-bucket-dev"
    key          = "dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true

    assume_role = {
      role_arn     = "arn:aws:iam::660880135138:role/terraform-infra-deploy"
      session_name = "terraform-apply-session"
    }
  }
}
