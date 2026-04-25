################################################################################
# Aurora MySQL Serverless v2
################################################################################

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.project}-${var.environment}-aurora"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.10.4"

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]

  storage_encrypted = true

  backup_retention_period      = var.backup_retention_days
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project}-${var.environment}-aurora-final"

  lifecycle {
    ignore_changes = [master_password]
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-aurora"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_rds_cluster_instance" "this" {
  identifier         = "${var.project}-${var.environment}-aurora-1"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.environment}-aurora-1"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
