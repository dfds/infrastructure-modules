# Using the variant variables one can perform a blue/green update on Traefik,
# routing traffic gradually to a new version and then decomissioning an older
# version without downtime.

resource "aws_lb" "traefik" {
  count              = var.deploy_blue_variant || var.deploy_green_variant ? 1 : 0
  name               = var.name
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "application"
  security_groups = concat(
    var.deploy_blue_variant || var.deploy_green_variant ? [aws_security_group.traefik[0].id] : [],
    var.deploy_blue_variant ? [aws_security_group.traefik_blue[0].id] : [],
    var.deploy_green_variant ? [aws_security_group.traefik_green[0].id] : [],
    var.deploy_blue_variant && var.deploy_green_variant ? [aws_security_group.traefik_debug[0].id] : []
  )
  subnets = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.name
  }

  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "traefik_blue_variant" {
  count                = var.deploy_blue_variant ? 1 : 0
  name_prefix          = "b-${substr(var.cluster_name, 0, min(4, length(var.cluster_name)))}"
  port                 = var.blue_variant_target_http_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 300

  health_check {
    path     = var.blue_variant_health_check_path
    port     = var.blue_variant_target_admin_port
    protocol = "HTTP"
    matcher  = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "traefik_blue_variant" {
  for_each               = var.deploy_blue_variant ? var.autoscaling_group_ids : []
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_blue_variant[0].arn
}

resource "aws_lb_target_group" "traefik_green_variant" {
  count                = var.deploy_green_variant ? 1 : 0
  name_prefix          = "g-${substr(var.cluster_name, 0, min(4, length(var.cluster_name)))}"
  port                 = var.green_variant_target_http_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 300

  health_check {
    path     = var.green_variant_health_check_path
    port     = var.green_variant_target_admin_port
    protocol = "HTTP"
    matcher  = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "traefik_green_variant" {
  for_each               = var.deploy_green_variant ? var.autoscaling_group_ids : []
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_green_variant[0].arn
}

resource "aws_lb_listener" "traefik" {
  count             = var.deploy_blue_variant || var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type  = "forward"
    order = 1

    forward {

      stickiness {
        enabled  = true
        duration = 10
      }

      dynamic "target_group" {
        for_each = concat(
          var.deploy_blue_variant ? [
            {
              arn    = aws_lb_target_group.traefik_blue_variant[0].arn
              weight = var.blue_variant_weight
            }
          ] : [],
          var.deploy_green_variant ? [
            {
              arn    = aws_lb_target_group.traefik_green_variant[0].arn
              weight = var.green_variant_weight
            }
          ] : []
        )
        content {
          arn    = target_group.value["arn"]
          weight = target_group.value["weight"]
        }
      }
    }
  }
}

resource "aws_lb_listener" "traefik_blue_variant" {
  count             = var.deploy_blue_variant && var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik[0].arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_blue_variant[0].arn
    order            = 1
  }
}

resource "aws_lb_listener" "traefik_green_variant" {
  count             = var.deploy_blue_variant && var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik[0].arn
  port              = "9443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_green_variant[0].arn
    order            = 1
  }
}

resource "aws_lb_listener" "http-to-https" {
  count             = var.deploy_blue_variant || var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "traefik" {
  count       = var.deploy_blue_variant || var.deploy_green_variant ? 1 : 0
  name_prefix = "allow_traefik-${var.cluster_name}"
  description = "Allow traefik connection for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on standard HTTP port"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg tfsec:ignore:aws-ec2-no-public-ingress-sgr
  }

  ingress {
    description = "Ingress on standard HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg tfsec:ignore:aws-ec2-no-public-ingress-sgr
  }

  tags = {
    Name = "${var.cluster_name}-traefik-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "traefik_blue" {
  count       = var.deploy_blue_variant ? 1 : 0
  name_prefix = "allow_traefik_blue-${var.cluster_name}"
  description = "Allow traefik connection related to the blue variant for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on var.target_admin_port"
    from_port   = var.blue_variant_target_admin_port
    to_port     = var.blue_variant_target_admin_port
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.target_http_port to var.target_admin_port"
    from_port   = var.blue_variant_target_http_port
    to_port     = var.blue_variant_target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  tags = {
    Name = "${var.cluster_name}-traefik-blue-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "traefik_green" {
  count       = var.deploy_green_variant ? 1 : 0
  name_prefix = "allow_traefik_green-${var.cluster_name}"
  description = "Allow traefik connection related to the green variant for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on var.green_variant_target_admin_port"
    from_port   = var.green_variant_target_admin_port
    to_port     = var.green_variant_target_admin_port
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.green_variant_target_http_port to var.green_variant_target_admin_port"
    from_port   = var.green_variant_target_http_port
    to_port     = var.green_variant_target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  tags = {
    Name = "${var.cluster_name}-traefik-blue-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "traefik_debug" {
  count       = var.deploy_blue_variant && var.deploy_green_variant ? 1 : 0
  name_prefix = "allow_traefik_debug-${var.cluster_name}"
  description = "Allow traefik connection related to debugging a blue/green deployment for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on HTTPS port fixed at target of blue variant"
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  ingress {
    description = "Ingress on HTTPS port fixed at target of green variant"
    from_port   = 9443
    to_port     = 9443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  tags = {
    Name = "${var.cluster_name}-traefik-debug-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "allow_traefik_blue" {
  count                    = var.deploy_blue_variant ? 1 : 0
  description              = "Ingress on HTTP port for the Traefik blue variant."
  type                     = "ingress"
  from_port                = var.blue_variant_target_http_port
  to_port                  = var.blue_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik[0].id

  security_group_id = var.nodes_sg_id
}

resource "aws_security_group_rule" "allow_traefik_green" {
  count                    = var.deploy_green_variant ? 1 : 0
  description              = "Ingress on HTTP port for the Traefik green variant."
  type                     = "ingress"
  from_port                = var.green_variant_target_http_port
  to_port                  = var.green_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik[0].id

  security_group_id = var.nodes_sg_id
}
