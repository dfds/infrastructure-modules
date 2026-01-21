# Using the variant variables one can perform a blue/green update on Traefik,
# routing requests gradually to a new version and then decommissioning an older
# version without downtime.

resource "aws_lb" "traefik_auth" {
  name               = var.name
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "application"
  security_groups = concat(
    [aws_security_group.traefik_auth.id],
    [aws_security_group.traefik_auth_blue.id],
    [aws_security_group.traefik_auth_green.id],
  )
  subnets = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.name
  }

  drop_invalid_header_fields = true
  idle_timeout               = 300
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "traefik_auth_blue_variant" {
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

resource "aws_autoscaling_attachment" "traefik_auth_blue_variant" {
  for_each               = var.autoscaling_group_ids
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_auth_blue_variant.arn
}

resource "aws_lb_target_group" "traefik_auth_green_variant" {
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

resource "aws_autoscaling_attachment" "traefik_auth_green_variant" {
  for_each               = var.autoscaling_group_ids
  autoscaling_group_name = each.key
  lb_target_group_arn    = aws_lb_target_group.traefik_auth_green_variant.arn
}

resource "aws_lb_listener" "traefik_auth" {
  load_balancer_arn = aws_lb.traefik_auth.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type  = "authenticate-oidc"
    order = 1

    authenticate_oidc {
      authorization_endpoint = "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/v2.0/authorize"
      client_id              = var.azure_client_id
      client_secret          = var.azure_client_secret
      issuer                 = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0"
      token_endpoint         = "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/v2.0/token"
      user_info_endpoint     = "https://graph.microsoft.com/oidc/userinfo"
    }
  }

  default_action {
    type  = "forward"
    order = 2

    dynamic "forward" {
      for_each = [[
        {
          arn    = aws_lb_target_group.traefik_auth_blue_variant.arn
          weight = var.blue_variant_weight
        },
        {
          arn    = aws_lb_target_group.traefik_auth_green_variant.arn
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
  load_balancer_arn = aws_lb.traefik_auth.arn
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

resource "aws_security_group" "traefik_auth" {
  name_prefix = "allow_traefik-${var.cluster_name}-auth"
  description = "Allow traefik connection for ${var.cluster_name} with authentication via oidc"
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

  egress {
    description = "Egress on standard HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg tfsec:ignore:aws-ec2-no-public-ingress-sgr tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  tags = {
    Name = "${var.cluster_name}-traefik-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "traefik_auth_blue" {
  name_prefix = "allow_traefik_blue-${var.cluster_name}-auth"
  description = "Allow traefik connection related to the blue variant for ${var.cluster_name} with authentication via oidc"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on blue_variant_target_admin_port"
    from_port   = var.blue_variant_target_admin_port
    to_port     = var.blue_variant_target_admin_port
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.blue_variant_target_http_port to var.blue_variant_target_admin_port"
    from_port   = var.blue_variant_target_http_port
    to_port     = var.blue_variant_target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  tags = {
    Name = "${var.cluster_name}-traefik-blue-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

#trivy:ignore:AVD-AWS-0104 Security group rule allows unrestricted egress to any IP address
resource "aws_security_group" "traefik_auth_green" {
  name_prefix = "allow_traefik_green-${var.cluster_name}-auth"
  description = "Allow traefik connection related to the green variant for ${var.cluster_name} with authentication via oidc"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on green_variant_target_admin_port"
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
    Name = "${var.cluster_name}-traefik-green-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_traefik_auth_blue" {
  description              = "Ingress on HTTP port for the Traefik blue variant."
  type                     = "ingress"
  from_port                = var.blue_variant_target_http_port
  to_port                  = var.blue_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik_auth.id

  security_group_id = var.nodes_sg_id
}

resource "aws_security_group_rule" "allow_traefik_auth_green" {
  description              = "Ingress on HTTP port for the Traefik green variant."
  type                     = "ingress"
  from_port                = var.green_variant_target_http_port
  to_port                  = var.green_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik_auth.id

  security_group_id = var.nodes_sg_id
}
