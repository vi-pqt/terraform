#######################
# Aurora Cluster
#######################
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.project_name}-${var.stage}-cluster"
  engine             = var.aurora_engine
  engine_version     = var.aurora_engine_version

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  vpc_security_group_ids = [var.data_sg]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  availability_zones     = var.availability_zones

  storage_encrypted = true


  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.stage}-cluster-final"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-cluster"
    Tier = "Data"
  })
}

resource "aws_rds_cluster_instance" "this" {
  identifier           = "${var.project_name}-${var.stage}-cluster-instance-1"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = var.aurora_instance_class
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.this.name
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-cluster-instance-1"
    Tier = "Data"
  })
}

resource "aws_db_subnet_group" "this" {
  description = "Data Subnet Group for Aurora Cluster"
  name        = "${var.project_name}-${var.stage}-db-subnet-group"
  subnet_ids  = var.data_subnets

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.stage}-db-subnet-group"
    Tier = "Data"
  })
}
