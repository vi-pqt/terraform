output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc_main.id
}

output "public_subnets" {
  description = "Public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnets" {
  description = "Private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "data_subnets" {
  description = "Data subnets"
  value       = aws_subnet.data_subnets[*].id
}

output "public_sg" {
  description = "Public security groups"
  value       = aws_security_group.public_sg.id
}

output "private_sg" {
  description = "Private security groups"
  value       = aws_security_group.private_sg[*].id
}

output "data_sg" {
  description = "Data security groups"
  value       = aws_security_group.data_sg.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat_gw[*].id
}
