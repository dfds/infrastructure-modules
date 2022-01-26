resource "aws_lb" "traefik_auth" {
  count              = var.deploy ? 1 : 0
  name               = var.name
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public
  load_balancer_type = "application"
  security_groups    = [aws_security_group.traefik_auth[0].id]
  subnets            = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.name
  }

  drop_invalid_header_fields = true
}

resource "aws_autoscaling_attachment" "traefik_auth" {
  count                  = var.deploy ? length(var.autoscaling_group_ids) : 0
  autoscaling_group_name = var.autoscaling_group_ids[count.index]
  alb_target_group_arn   = aws_lb_target_group.traefik_auth[0].arn
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

resource "aws_lb_listener" "traefik_auth" {
  count             = var.deploy ? 1 : 0
  load_balancer_arn = aws_lb.traefik_auth[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type = "authenticate-oidc"

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
  }
}

resource "aws_lb_listener" "http-to-https" {
  count             = var.deploy ? 1 : 0
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
  count       = var.deploy ? 1 : 0
  name_prefix = "allow_traefik-${var.cluster_name}-auth"
  description = "Allow traefik connection for ${var.cluster_name} with authentication via oidc"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on standard HTTP port"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  ingress {
    description = "Ingress on standard HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sg
  }

  ingress {
    description = "Ingress on target_admin_port"
    from_port = var.target_admin_port
    to_port   = var.target_admin_port
    protocol  = "TCP"
    self      = true
  }

  egress {
    description = "Egress from var.target_http_port to var.target_admin_port"
    from_port   = var.target_http_port
    to_port     = var.target_admin_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  egress {
    description = "Egress on standard HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sg
  }

  tags = {
    Name = "${var.cluster_name}-traefik-auth-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# tfsec:ignore:aws-vpc-add-description-to-security-group
resource "aws_security_group_rule" "allow_traefik_auth" {
  count                    = var.deploy ? 1 : 0
  type                     = "ingress"
  from_port                = var.target_http_port
  to_port                  = var.target_admin_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.traefik_auth[0].id

  security_group_id = var.nodes_sg_id
}

