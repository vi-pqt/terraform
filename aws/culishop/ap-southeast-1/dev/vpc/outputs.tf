output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnets"
  value       = module.vpc.private_subnets
}

output "data_subnets" {
  description = "Data subnets"
  value       = module.vpc.data_subnets
}

output "public_sg" {
  description = "Public security groups"
  value       = module.vpc.public_sg
}

output "private_sg" {
  description = "Private security groups"
  value       = module.vpc.private_sg
}

output "alb_sg" {
  description = "ALB security groups"
  value       = module.vpc.alb_sg
}

output "data_sg" {
  description = "Data security groups"
  value       = module.vpc.data_sg
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "aws_caller_identity" {
  description = "AWS Caller Identity"
  value       = data.aws_caller_identity.current.account_id
}
