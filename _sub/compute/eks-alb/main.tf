# Using the variant variables one can perform a blue/green update on Traefik,
# routing requests gradually to a new version and then decommissioning an older
# version without downtime.

resource "aws_lb" "traefik" {
  name               = var.name
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "application"
  security_groups = concat(
    [aws_security_group.traefik.id],
    [aws_security_group.traefik_blue.id],
    [aws_security_group.traefik_green.id]
  )
  subnets = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = true
    prefix  = var.name
  }

  drop_invalid_header_fields = true
  idle_timeout               = 300
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "traefik_blue_variant" {
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
  for_each               = var.autoscaling_group_ids
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_blue_variant.arn
}

resource "aws_lb_target_group" "traefik_green_variant" {
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
  for_each               = var.autoscaling_group_ids
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_green_variant.arn
}

resource "aws_lb_listener" "traefik" {
  load_balancer_arn = aws_lb.traefik.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type  = "forward"
    order = 1

    dynamic "forward" {
      for_each = [[
        {
          arn    = aws_lb_target_group.traefik_blue_variant.arn
          weight = var.blue_variant_weight
        },
        {
          arn    = aws_lb_target_group.traefik_green_variant.arn
          weight = var.green_variant_weight
        }
      ]]
      content {
        stickiness {
          enabled  = true
          duration = 10
        }

        dynamic "target_group" {
          for_each = forward.value
          content {
            arn    = target_group.value["arn"]
            weight = target_group.value["weight"]
          }
        }
      }
    }
  }
}

resource "aws_lb_listener" "http-to-https" {
  load_balancer_arn = aws_lb.traefik.arn
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
  name_prefix = "allow_traefik-${var.cluster_name}"
  description = "Allow traefik connection for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  #checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
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

#trivy:ignore:AVD-AWS-0104 Security group rule allows unrestricted egress to any IP address
resource "aws_security_group" "traefik_green" {
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

resource "aws_security_group_rule" "allow_traefik_blue" {
  description              = "Ingress on HTTP port for the Traefik blue variant."
  type                     = "ingress"
  from_port                = var.blue_variant_target_http_port
  to_port                  = var.blue_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik.id

  security_group_id = var.nodes_sg_id
}

resource "aws_security_group_rule" "allow_traefik_green" {
  description              = "Ingress on HTTP port for the Traefik green variant."
  type                     = "ingress"
  from_port                = var.green_variant_target_http_port
  to_port                  = var.green_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik.id

  security_group_id = var.nodes_sg_id
}
