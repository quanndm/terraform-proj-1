provider "aws" {
  region = var.region
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.bastion_vpc_sg_id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    encrypted   = true
  }

  tags = {
    Name  = "Baston-instance"
    Owner = "Quanndm"
  }
}
