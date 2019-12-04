resource "aws_lb" "nlb" {
  count              = "${var.deploy}"
  name               = "${var.cluster_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_autoscaling_attachment" "nlb" {
  count                  = "${var.deploy ? length(var.autoscaling_group_ids) : 0}"
  autoscaling_group_name = "${var.autoscaling_group_ids[count.index]}"
  alb_target_group_arn   = "${aws_lb_target_group.nlb.arn}"
}

resource "aws_lb_target_group" "nlb" {
  count       = "${var.deploy}"
  name_prefix = "${substr(var.cluster_name, 0, min(6, length(var.cluster_name)))}"
  port        = 30000
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

#
resource "aws_lb_listener" "nlb" {
  count             = "${var.deploy}"
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.nlb_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nlb.arn}"
  }
}

#
resource "aws_security_group_rule" "allow_argo" {
  count     = "${var.deploy}"
  type      = "ingress"
  from_port = 30000
  to_port   = 30001
  protocol  = "tcp"

  cidr_blocks       = ["${var.cidr_blocks}"]
  security_group_id = "${var.nodes_sg_id}"
}
