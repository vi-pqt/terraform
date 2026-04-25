output "primary_endpoint_address" {
  description = "Primary endpoint address of the replication group"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "port" {
  description = "ElastiCache Redis port"
  value       = aws_elasticache_replication_group.this.port
}

output "replication_group_id" {
  description = "Replication group identifier"
  value       = aws_elasticache_replication_group.this.id
}

output "security_group_id" {
  description = "Security group ID used by the replication group"
  value       = var.security_group_id
}
