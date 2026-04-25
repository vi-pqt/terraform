# ============================================================
# Bastion Host for database access via SSM Session Manager
# Used in: Lab 09 (Aurora MySQL migration)
# Toggle: var.enable_bastion
# Connect: aws ssm start-session --target <instance_id>
# ============================================================

module "bastion" {
  source = "../../../../modules/aws/bastion"
  count  = var.enable_bastion ? 1 : 0

  project     = var.project
  environment = var.environment

  subnet_id          = local.private_app_subnets[0]
  security_group_ids = [local.app_sg_id]

  user_data = templatefile("${path.module}/templates/bastion-userdata.sh.tftpl", {
    migration_001 = file("${var.culishop_source_path}/db/migrations/001_create_products.sql")
    migration_002 = file("${var.culishop_source_path}/db/migrations/002_create_orders.sql")
    migration_003 = file("${var.culishop_source_path}/db/migrations/003_create_carts.sql")
    seed_products = file("${var.culishop_source_path}/db/seed/products.sql")
  })
}
