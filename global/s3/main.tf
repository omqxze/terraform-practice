provider "aws" {
  region = "ap-northeast-2"
}
# S3 버킷 생성
resource "aws_s3_bucket" "example_s3" {
  bucket = "terraform-state-cloudwave-ddos"
  lifecycle {
    #true로 설정할 경우 수동으로 s3버킷을 삭제해줘야한다
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "example_version" {
  bucket = aws_s3_bucket.example_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example_encry" {
  bucket = aws_s3_bucket.example_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "example_ab" {
  bucket = aws_s3_bucket.example_s3.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# DynamoDB 테이블 생성
resource "aws_dynamodb_table" "example_db_table" {
  hash_key = "LockID"
  name     = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# 백엔드 구성 추가
terraform {
  backend "s3" {
    bucket = "terraform-state-cloudwave-ddos"
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform_locks"
    encrypt = true
  }
}

