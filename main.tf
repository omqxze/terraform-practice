provider "aws" {
  region = "ap-northeast-2"
}

#autoscaling group
resource "aws_launch_configuration" "example_launch" {
  image_id      = "ami-0f3a440bbcff3d043"
  instance_type = "t3.micro"
  security_groups = [aws_security_group.example_sg.id]
  user_data  =  <<-EOF
                #!/bin/bash
                echo  "I WANNA GO HOME RIGHT NOW"  >  index.html
                nohup  busybox  httpd  -f  -p  ${var.server_port}  &
                EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example_asg" {
  launch_configuration = aws_launch_configuration.example_launch.name
  max_size = 10
  min_size = 2
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.example_alb_tg.arn]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "terraform-example-asg"
  }
}

#application loadbalancer
resource "aws_lb" "example_alb" {
  name = "terraform-example-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.example_alb_sg.id]
}

resource "aws_lb_listener" "example_alb_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port = 80
  protocol = "HTTP"
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
  name = "terraform-example-alb-sg"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "example_alb_tg" {
  name = "terraform-example-alb-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
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
  name  =  "terraform-example-instance"

  ingress  {
    from_port    =  var.server_port
    to_port      =  var.server_port
    protocol     =  "tcp"
    cidr_blocks  =  [ "0.0.0.0/0" ]
  }
}

output "alb_dns_name" {
  value = aws_lb.example_alb.dns_name
  description="The Domain Name of the LoadBalancer"
}

variable "server_port" {
  description = "The port. the server will use for HTTP requests"
  type = number
  default = 8080
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


