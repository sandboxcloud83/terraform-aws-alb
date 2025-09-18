# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  drop_invalid_header_fields = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs.enabled ? [1] : []
    content {
      bucket  = var.access_logs.bucket_name
      prefix  = lookup(var.access_logs, "prefix", null)
      enabled = true
    }
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# Target Groups
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name        = "${var.name}-${each.key}"
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type
  vpc_id      = var.vpc_id

  health_check {
    path                = each.value.health_check_path
    port                = each.value.health_check_port
    matcher             = each.value.health_check_matcher
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  tags = merge(
    { "Name" = "${var.name}-${each.key}" },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# Listeners
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "main" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" ? var.listener_ssl_policy : null
  certificate_arn   = each.value.certificate_arn

  dynamic "default_action" {
    for_each = each.value.action_type == "forward" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main[each.value.target_group_key].arn
    }
  }

  dynamic "default_action" {
    for_each = each.value.action_type == "redirect" ? [1] : []
    content {
      type = "redirect"
      redirect {
        protocol    = each.value.redirect.protocol
        port        = each.value.redirect.port
        status_code = each.value.redirect.status_code
      }
    }
  }
}
