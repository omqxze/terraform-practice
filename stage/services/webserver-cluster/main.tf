provider "aws" {
  region = "ap-northeast-2"
}
module "webserver_cluster" {
  source = "../../../module/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket="terraform-state-cloudwave-ddos"
  db_remote_state_key="stage/data-stores/mysql/terraform.tfstate"

  instance_type="t3.micro"
  min_size=2
  max_size=10
}

resource "aws_security_group_rule" "allow_test_inbound" {
  from_port         = 12345
  protocol          = "tcp"
  security_group_id = module.webserver_cluster.alb_sg_id
  to_port           = 12345
  type              = "ingress"
}



