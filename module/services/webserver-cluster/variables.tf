variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the db's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the db's remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 Instances"
  type = string
}

variable "min_size" {
  description = "The minimum number"
  type = number
}

variable "max_size" {
  description = "The maximum number"
  type = number
}

variable "server_port" {
  description = "The port. the server will use for HTTP requests"
  type = number
  default = 8080
}

