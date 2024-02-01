provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_db_instance" "example_db" {
  instance_class = "db.t2.micro"
  identifier_prefix = "terraform-mysql"
  engine = "mysql"
  allocated_storage = 10
  skip_final_snapshot = true
  db_name = "test_database"

  username = var.db_username
  password = var.db_password
}

terraform {
  backend "s3" {
    bucket = "terraform-state-cloudwave-ddos"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform_locks"
    encrypt = true
  }
}
