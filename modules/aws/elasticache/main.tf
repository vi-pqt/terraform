################################################################################
# ElastiCache Valkey (AWS-recommended Redis replacement)
# Drop-in compatible with Redis OSS 7.x clients
################################################################################

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-valkey"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-valkey-subnet-group"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.project}-${var.environment}-valkey"
  description          = "${var.project} ${var.environment} Valkey replication group"

  engine         = "valkey"
  engine_version = "7.2"
  node_type      = var.node_type
  port           = 6379

  parameter_group_name = "default.valkey7"
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [var.security_group_id]

  num_cache_clusters = var.num_cache_clusters

  automatic_failover_enabled = var.num_cache_clusters >= 2
  multi_az_enabled           = var.num_cache_clusters >= 2

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.auth_token

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-valkey"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
