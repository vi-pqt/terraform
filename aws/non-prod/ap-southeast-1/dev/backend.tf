terraform {
  backend "s3" {
    bucket  = "culishop-tf-state-bucket-dev"
    key     = "dev/terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "culishop"
  }
}
