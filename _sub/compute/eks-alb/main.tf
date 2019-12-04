resource "aws_lb" "traefik" {
  count              = "${var.deploy}"
  name               = "${var.cluster_name}-traefik-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.traefik.id}"]
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_autoscaling_attachment" "traefik" {
  count                  = "${var.deploy ? length(var.autoscaling_group_ids) : 0}"
  autoscaling_group_name = "${var.autoscaling_group_ids[count.index]}"
  alb_target_group_arn   = "${aws_lb_target_group.traefik.arn}"
}

resource "aws_lb_target_group" "traefik" {
  count       = "${var.deploy}"
  name_prefix = "${substr(var.cluster_name, 0, min(6, length(var.cluster_name)))}"
  port        = 30000
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"

  health_check {
    path     = "/dashboard/"
    port     = 30001
    protocol = "HTTP"
    matcher  = 200
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "traefik" {
  count             = "${var.deploy}"
  load_balancer_arn = "${aws_lb.traefik.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.traefik.arn}"
  }
}

resource "aws_lb_listener" "http-to-https" {
  count             = "${var.deploy}"
  load_balancer_arn = "${aws_lb.traefik.arn}"
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
  count       = "${var.deploy}"
  name        = "allow_traefik-${var.cluster_name}"
  description = "Allow traefik connection for ${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30001
    to_port   = 30001
    protocol  = "TCP"
    self      = true
  }

  egress {
    from_port   = 30000
    to_port     = 30001
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster_name}-traefik-sg"
  }
}

resource "aws_security_group_rule" "allow_traefik" {
  count                    = "${var.deploy}"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 30001
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.traefik.id}"

  security_group_id = "${var.nodes_sg_id}"
}
