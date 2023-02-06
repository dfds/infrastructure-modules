# Using the variant variables one can perform a blue/green update on Traefik,
# routing traffic gradually to a new version and then decomissioning an older
# version without downtime.

# TODO(emil): Rename the original instance resources and variables to specify that
# they refer to the "blue" variant after the "blue" instance is destroyed.
# This is to avoid downtime or having to reimport resources due to renaming.

resource "aws_lb" "traefik_auth" {
  count              = var.deploy || var.deploy_green_variant ? 1 : 0
  name               = var.name
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "application"
  security_groups = concat(
    var.deploy || var.deploy_green_variant ? [aws_security_group.traefik_auth[0].id] : [],
    var.deploy ? [aws_security_group.traefik_auth_blue[0].id] : [],
    var.deploy_green_variant ? [aws_security_group.traefik_auth_green[0].id] : [],
    var.deploy && var.deploy_green_variant ? [aws_security_group.traefik_auth_debug[0].id] : [],
  )
  subnets = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.name
  }

  drop_invalid_header_fields = true
}

resource "aws_lb_target_group" "traefik_auth" {
  count                = var.deploy ? 1 : 0
  name_prefix          = substr(var.cluster_name, 0, min(6, length(var.cluster_name)))
  port                 = var.target_http_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 300

  health_check {
    path     = var.health_check_path
    port     = var.target_admin_port
    protocol = "HTTP"
    matcher  = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "traefik_auth" {
  count                  = var.deploy ? length(var.autoscaling_group_ids) : 0
  autoscaling_group_name = var.autoscaling_group_ids[count.index]
  lb_target_group_arn    = aws_lb_target_group.traefik_auth[0].arn
}

resource "aws_lb_target_group" "traefik_auth_variant" {
  count                = var.deploy_green_variant ? 1 : 0
  name_prefix          = "v${substr(var.cluster_name, 0, min(5, length(var.cluster_name)))}"
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

resource "aws_autoscaling_attachment" "traefik_auth_variant" {
  count                  = var.deploy_green_variant ? length(var.autoscaling_group_ids) : 0
  autoscaling_group_name = var.autoscaling_group_ids[count.index]
  lb_target_group_arn    = aws_lb_target_group.traefik_auth_variant[0].arn
}

resource "aws_lb_listener" "traefik_auth" {
  count             = var.deploy || var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik_auth[0].arn
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

    forward {

      stickiness {
        enabled  = true
        duration = 10
      }

      dynamic "target_group" {
        for_each = concat(
          var.deploy ? [
            {
              arn    = aws_lb_target_group.traefik_auth[0].arn
              weight = var.weight
            }
          ] : [],
          var.deploy_green_variant ? [
            {
              arn    = aws_lb_target_group.traefik_auth_variant[0].arn
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

resource "aws_lb_listener" "traefik_auth_variant_blue" {
  count             = var.deploy && var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik_auth[0].arn
  port              = "8443"
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
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_auth[0].arn
    order            = 2
  }
}

resource "aws_lb_listener" "traefik_auth_variant_green" {
  count             = var.deploy && var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik_auth[0].arn
  port              = "9443"
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
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_auth_variant[0].arn
    order            = 2
  }
}

resource "aws_lb_listener" "http-to-https" {
  count             = var.deploy || var.deploy_green_variant ? 1 : 0
  load_balancer_arn = aws_lb.traefik_auth[0].arn
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
  count       = var.deploy || var.deploy_green_variant ? 1 : 0
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

  # TODO(emil): Remove these security group rules after the initial application
  # to separate these rules into separate security groups.
  ingress {
    description = "Ingress on target_admin_port"
    from_port   = var.target_admin_port
    to_port     = var.target_admin_port
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.target_http_port to var.target_admin_port"
    from_port   = var.target_http_port
    to_port     = var.target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg tfsec:ignore:aws-ec2-no-public-ingress-sgr tfsec:ignore:aws-ec2-no-public-egress-sgr
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
  count       = var.deploy ? 1 : 0
  name_prefix = "allow_traefik_blue-${var.cluster_name}-auth"
  description = "Allow traefik connection related to the blue variant for ${var.cluster_name} with authentication via oidc"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on target_admin_port"
    from_port   = var.target_admin_port
    to_port     = var.target_admin_port
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.target_http_port to var.target_admin_port"
    from_port   = var.target_http_port
    to_port     = var.target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  tags = {
    Name = "${var.cluster_name}-traefik-blue-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "traefik_auth_green" {
  count       = var.deploy_green_variant ? 1 : 0
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

resource "aws_security_group" "traefik_auth_debug" {
  count       = var.deploy && var.deploy_green_variant ? 1 : 0
  name_prefix = "allow_traefik_debug-${var.cluster_name}-auth"
  description = "Allow traefik connection related to debugging a blue/green deployment for ${var.cluster_name} with authentication via oidc"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on HTTPS port fixed at target of of the blue variant"
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  egress {
    description = "Egress on HTTPS port fixed at target of of the blue variant"
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  ingress {
    description = "Ingress on HTTPS port fixed at target of of the green variant"
    from_port   = 9443
    to_port     = 9443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  egress {
    description = "Egress on HTTPS port fixed at target of of the green variant"
    from_port   = 9443
    to_port     = 9443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  tags = {
    Name = "${var.cluster_name}-traefik-debug-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_traefik_auth" {
  count                    = var.deploy ? 1 : 0
  description              = "Ingress on HTTP port for the Traefik blue variant."
  type                     = "ingress"
  from_port                = var.target_http_port
  to_port                  = var.target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik_auth[0].id

  security_group_id = var.nodes_sg_id
}

resource "aws_security_group_rule" "allow_traefik_auth_green" {
  count                    = var.deploy_green_variant ? 1 : 0
  description              = "Ingress on HTTP port for the Traefik green variant."
  type                     = "ingress"
  from_port                = var.green_variant_target_http_port
  to_port                  = var.green_variant_target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik_auth[0].id

  security_group_id = var.nodes_sg_id
}
