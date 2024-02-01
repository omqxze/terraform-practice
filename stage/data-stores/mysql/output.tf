output "address" {
  value = aws_db_instance.example_db.address
  description = "connect this endpoint"
}

output "port" {
  value = aws_db_instance.example_db.port
  description = "the listening port"
}
