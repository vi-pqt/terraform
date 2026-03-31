output "ecs_service_name" {
  value = aws_ecs_service.name[*].name
}

output "ecs_service_arn" {
  value = aws_ecs_service.name[*].arn
}

output "ecs_service_id" {
  value = aws_ecs_service.name[*].id
}

output "ecs_service_task_definition" {
  value = aws_ecs_service.name[*].task_definition
}
