provider "aws" {
  region = var.region
}

resource "aws_instance" "mongo-instance" {
  ami                    = var.mongo-instance-ami
  instance_type          = var.mongo-instance-type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.mongo-instance-vpc-sg-id]

  root_block_device {
    volume_size = 10
    encrypted   = true
  }

  user_data = filebase64("${path.module}/install.sh")

  tags = {
    Name  = "Mongo-instance"
    Owner = "Quanndm"
  }
}
