# ============================================================
# INGRESS rules
# ============================================================

# Self-referencing rule: allow all traffic within app SG for Service Connect mesh
resource "aws_vpc_security_group_ingress_rule" "app_mesh" {
  security_group_id            = local.app_sg_id
  referenced_security_group_id = local.app_sg_id
  ip_protocol                  = "-1"
  description                  = "Service Connect mesh - all traffic within app tier"
}

# ALB → apiservice:8090
resource "aws_vpc_security_group_ingress_rule" "app_from_alb_8090" {
  security_group_id            = local.app_sg_id
  referenced_security_group_id = local.alb_sg_id
  from_port                    = 8090
  to_port                      = 8090
  ip_protocol                  = "tcp"
  description                  = "ALB to apiservice"
}

# ALB → reactfrontend:80
resource "aws_vpc_security_group_ingress_rule" "app_from_alb_80" {
  security_group_id            = local.app_sg_id
  referenced_security_group_id = local.alb_sg_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "ALB to reactfrontend"
}

# ============================================================
# EGRESS rules (critical — without these, Service Connect mesh fails)
# ============================================================

# Self-referencing egress: allow all traffic within app SG for mesh
resource "aws_vpc_security_group_egress_rule" "app_mesh_egress" {
  security_group_id            = local.app_sg_id
  referenced_security_group_id = local.app_sg_id
  ip_protocol                  = "-1"
  description                  = "Service Connect mesh - all egress within app tier"
}

# ALB egress to apiservice:8090
resource "aws_vpc_security_group_egress_rule" "alb_to_apiservice" {
  security_group_id            = local.alb_sg_id
  referenced_security_group_id = local.app_sg_id
  from_port                    = 8090
  to_port                      = 8090
  ip_protocol                  = "tcp"
  description                  = "ALB to apiservice"
}

# ALB egress to reactfrontend:80
resource "aws_vpc_security_group_egress_rule" "alb_to_reactfrontend" {
  security_group_id            = local.alb_sg_id
  referenced_security_group_id = local.app_sg_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "ALB to reactfrontend"
}
