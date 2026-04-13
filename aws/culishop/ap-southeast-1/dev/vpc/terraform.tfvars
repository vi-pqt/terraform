project_name = "culishop"
environment  = "dev"
stage        = "dev"
region       = "ap-southeast-1"

# VPC
vpc_cidr_block     = "10.0.0.0/16"
public_subnets     = ["10.0.0.0/24", "10.0.16.0/24", "10.0.32.0/24"]
private_subnets    = ["10.0.48.0/24", "10.0.64.0/24", "10.0.80.0/24"]
data_subnets       = ["10.0.96.0/24", "10.0.112.0/24", "10.0.128.0/24"]
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
