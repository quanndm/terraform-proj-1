provider "aws" {
  region = var.region
}

resource "aws_launch_template" "alb-launch-tpl" {
  name = "alb-launch-tpl"

  image_id               = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.webserver_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name  = "FrontendApp"
      Owner = "Quanndm"
    }
  }
  user_data = base64encode(data.template_cloudinit_config.config.rendered)
}


resource "aws_lb" "alb1" {
  name                       = "alb1"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnets
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    "Environment" = "Prod"
  }
}

resource "aws_alb_target_group" "alb-webserver-target-group" {
  vpc_id   = var.vpc_id
  port     = 80
  protocol = "HTTP"

  health_check {
    path                = "/"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 6
    timeout             = 5
  }
}

resource "aws_alb_target_group" "alb-api-target-group" {
  vpc_id   = var.vpc_id
  port     = 8080
  protocol = "HTTP"

  health_check {
    path                = "/ok"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 6
    timeout             = 5
  }
}

resource "aws_alb_listener" "alb-webserver-listener" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-webserver-target-group.arn
  }
}

resource "aws_alb_listener_rule" "alb-frontend-listener-rule" {
  listener_arn = aws_alb_listener.alb-webserver-listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-webserver-target-group.arn
  }
}

resource "aws_alb_listener_rule" "alb-api-listener-rule" {
  listener_arn = aws_alb_listener.alb-webserver-listener.arn
  priority     = 10

  condition {
    path_pattern {
      values = [
        "/languages",
        "/languages/*",
        "/languages/*/**",
        "/ok"
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-api-target-group.arn
  }
}


####################

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.private_subnets

  desired_capacity = var.asg_desired
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  target_group_arns = [aws_alb_target_group.alb-webserver-target-group.arn, aws_alb_target_group.alb-api-target-group.arn]

  launch_template {
    id      = aws_launch_template.alb-launch-tpl.id
    version = "$Latest"
  }
}
