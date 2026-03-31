output "ecr_repository_url" {
  description = "ECR repository URLs"
  value       = aws_ecr_repository.ecr_repo[*].repository_url
}
