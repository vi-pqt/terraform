output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.alb_public[*].id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.alb_public[*].dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.alb_public[*].zone_id
}
