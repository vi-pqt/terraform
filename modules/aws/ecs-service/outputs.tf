output "ecs_service_name" {
  value = aws_ecs_service.ecs_services[*].name
}

output "ecs_service_arn" {
  value = aws_ecs_service.ecs_services[*].arn
}

output "ecs_service_id" {
  value = aws_ecs_service.ecs_services[*].id
}
