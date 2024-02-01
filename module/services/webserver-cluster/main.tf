#autoscaling group
resource "aws_launch_configuration" "example_launch" {
  image_id      = "ami-0f3a440bbcff3d043"
  instance_type = var.instance_type
  security_groups = [aws_security_group.example_sg.id]
  user_data  =  templatefile("${path.module}/user-data.sh",{
    server_port=var.server_port
    db_address=data.terraform_remote_state.db.outputs.address
    db_port=data.terraform_remote_state.db.outputs.port
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example_asg" {
  launch_configuration = aws_launch_configuration.example_launch.name
  max_size = var.max_size
  min_size = var.min_size
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.example_alb_tg.arn]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.cluster_name
  }
}

#application loadbalancer
resource "aws_lb" "example_alb" {
  name = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.example_alb_sg.id]
}

resource "aws_lb_listener" "example_alb_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port = local.http_port
  protocol = local.http_protocol
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: i can't find page"
      status_code = "404"
    }
  }
}

resource "aws_security_group" "example_alb_sg" {
  name = "${var.cluster_name}-lb-sg"
}

resource "aws_security_group_rule" "example_ingress" {
  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.example_alb_sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "example_egress" {
  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.example_alb_sg.id
  type = "egress"
}

resource "aws_lb_target_group" "example_alb_tg" {
  name = "${var.cluster_name}-alb-tg"
  port = var.server_port
  protocol = local.http_protocol
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = local.http_protocol
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "example_rule" {
  listener_arn = aws_lb_listener.example_alb_listener.arn
  priority = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.example_alb_tg.arn
  }
}

resource  "aws_security_group" "example_sg"  {
  name  =  "${var.cluster_name}-sg"

  ingress  {
    from_port    =  var.server_port
    to_port      =  var.server_port
    protocol     =  local.tcp_protocol
    cidr_blocks  =  local.all_ips
  }
}
