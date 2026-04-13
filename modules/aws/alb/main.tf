########################
# ALB
########################
resource "aws_lb" "alb_public" {
  count              = var.is_enable_alb ? 1 : 0
  name               = "${var.project_name}-${var.stage}-alb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-alb"
      Tier = "Public"
    }
  )
}

resource "aws_lb_target_group" "alb_target_group" {
  for_each = var.target_groups

  name        = "${var.project_name}-${var.stage}-tg-${substr(each.key, 0, 12)}" #culishop-prod-apisvc-tg
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = each.value.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = each.value.health_check_matcher
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-tg-${each.key}"
    }
  )
}

resource "aws_lb_listener" "alb_listener" {
  count             = var.is_enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.alb_public[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group[0].arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.stage}-listener"
    }
  )
}
