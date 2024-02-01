provider "aws" {
  region = "ap-northeast-2"
}
module "webserver_cluster" {
  source = "../../../module/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket="terraform-state-cloudwave-ddos"
  db_remote_state_key="stage/data-stores/mysql/terraform.tfstate"

  instance_type="t3.micro"
  min_size=2
  max_size=10
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = module.webserver_cluster.asg_name
  scheduled_action_name  = "scale_out_during_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = module.webserver_cluster.asg_name
  scheduled_action_name  = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}






