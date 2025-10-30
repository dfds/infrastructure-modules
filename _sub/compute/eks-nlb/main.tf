resource "aws_lb" "nlb" {
  count              = var.deploy ? 1 : 0
  name               = "${var.cluster_name}-nlb"
  internal           = false #tfsec:ignore:aws-elbv2-alb-not-public tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  security_groups = var.deploy ? [aws_security_group.traefik[0].id, aws_security_group.traefik_deployment[0].id] : []
}

resource "aws_autoscaling_attachment" "nlb" {
  count                  = var.deploy ? length(var.autoscaling_group_ids) : 0
  autoscaling_group_name = var.autoscaling_group_ids[count.index]
  lb_target_group_arn    = aws_lb_target_group.nlb[0].arn
}

resource "aws_lb_target_group" "nlb" {
  count       = var.deploy ? 1 : 0
  name_prefix = substr(var.cluster_name, 0, min(6, length(var.cluster_name)))
  port        = var.target_http_port # 30000 #
  protocol    = "TCP"
  vpc_id      = var.vpc_id

  health_check {
    path     = var.health_check_path # "/ping" #
    port     = var.target_admin_port # 30001 #
    protocol = "HTTP"
    matcher  = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "nlb" {
  count             = var.deploy ? 1 : 0
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[0].arn
  }
}

resource "aws_lb_listener" "nlb_insecure" {
  count             = var.deploy ? 1 : 0
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[0].arn
  }
}


resource "aws_security_group_rule" "traefik" { # on the nodes
  count       = var.deploy ? 1 : 0
  type        = "ingress"
  description = "Allow inbound HTTP traffic"
  from_port   = var.target_http_port # 30000 #
  to_port     = var.target_admin_port # 30001 #
  protocol    = "tcp"

  security_group_id = var.nodes_sg_id

  source_security_group_id = aws_security_group.traefik[0].id
}

resource "aws_security_group" "traefik" {
  count       = var.deploy ? 1 : 0
  name_prefix = "allow_traefik-${var.cluster_name}-nlb"
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

resource "aws_security_group" "traefik_deployment" { # on the load balancer
  count       = var.deploy ? 1 : 0
  name_prefix = "allow_traefik_deployment-${var.cluster_name}"
  description = "Allow traefik connection related to the traefik deployment for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress on var.target_admin_port"
    from_port   = var.target_admin_port # 30001 #
    to_port     = var.target_admin_port # 31001 #
    protocol    = "TCP"
    self        = true
  }

  egress {
    description = "Egress from var.target_http_port to var.target_admin_port"
    from_port   = var.target_http_port # 30000 #
    to_port     = var.target_admin_port # 30001 #
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
