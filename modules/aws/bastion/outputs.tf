output "instance_id" {
  description = "Bastion EC2 instance ID (use with: aws ssm start-session --target <id>)"
  value       = aws_instance.bastion.id
}

output "private_ip" {
  description = "Bastion private IP address"
  value       = aws_instance.bastion.private_ip
}
