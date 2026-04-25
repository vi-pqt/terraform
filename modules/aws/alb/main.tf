# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Default listener (HTTP:80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targets[var.default_target].arn
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Target groups — one per service
resource "aws_lb_target_group" "targets" {
  for_each = var.target_groups

  name        = "${var.project}-${var.environment}-tg-${each.key}"
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

  tags = {
    Name        = "${var.project}-${var.environment}-tg-${each.key}"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Path-based listener rules (non-default targets)
resource "aws_lb_listener_rule" "rules" {
  for_each = {
    for k, v in var.target_groups : k => v
    if k != var.default_target && length(v.path_patterns) > 0
  }

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targets[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
