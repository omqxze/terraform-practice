output "alb_dns_name" {
  value = aws_lb.example_alb.dns_name
  description="The Domain Name of the LoadBalancer"
}

output "asg_name" {
  value = aws_autoscaling_group.example_asg.name
  description="The name of ASG"
}

output "alb_sg_id" {
  value = aws_security_group.example_alb_sg.id
  description="The ID of SG"
}
