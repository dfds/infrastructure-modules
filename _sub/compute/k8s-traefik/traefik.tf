# resource "local_file" "enable-traefik" {

#     content = "${local.config-map-aws-auth}"
#     filename = "${pathexpand("./.terraform/data/config-map-aws-auth.yaml")}"

#     provisioner "local-exec" {
#         command = "kubectl apply -f ${pathexpand("./apply-traefik.yaml")}"
#     }

#     depends_on = ["local_file.kubeconfig"]

# }

resource "kubernetes_service_account" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-controller"
    namespace = "kube-system"

    labels {
      k8s-app = "${var.traefik_k8s_name}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        k8s-app = "${var.traefik_k8s_name}"
      }
    }

    template {
      metadata {
        labels {
          k8s-app = "${var.traefik_k8s_name}"
          name    = "${var.traefik_k8s_name}"
        }
      }

      spec {
        service_account_name             = "${var.traefik_k8s_name}-ingress-controller"
        termination_grace_period_seconds = 60

        container {
          image = "traefik"
          name  = "${var.traefik_k8s_name}"

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "admin"
            container_port = 8080
          }

          args = ["--api", "--kubernetes", "--logLevel=INFO"]
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-service"
    namespace = "kube-system"
  }

  spec {
    selector {
      k8s-app = "${var.traefik_k8s_name}"
    }

    port {
      protocol    = "TCP"
      port        = 80
      node_port   = 30000
      target_port = 80
      name        = "web"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      node_port   = 30001
      target_port = 8080
      name        = "admin"
    }

    type = "NodePort"
  }
}

resource "aws_lb" "traefik" {
  name               = "${var.cluster_name}-traefik-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.traefik.id}"]
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_autoscaling_attachment" "traefik" {
  autoscaling_group_name = "${var.autoscaling_group_id}"
  alb_target_group_arn   = "${aws_lb_target_group.traefik.arn}"
}

resource "aws_lb_target_group" "traefik" {
  name_prefix = "${var.cluster_name}"
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
    from_port   = 30001
    to_port     = 30001
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
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
  type            = "ingress"
  from_port       = 30000
  to_port         = 30001
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.traefik.id}"

  security_group_id = "${var.nodes_sg_id}"
}
