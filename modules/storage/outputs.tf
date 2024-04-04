output "mongo_instance_private_ip" {
  value = aws_instance.mongo-instance.private_ip
}
