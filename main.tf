provider "aws" {
  region = var.region
}

# key pair
resource "aws_key_pair" "lab-key-pair" {
  key_name   = "lab-key-pair"
  public_key = file(var.key_path)
}

# module network
module "network" {
  source             = "./modules/network"
  region             = var.region
  availability_zones = var.availability_zones
  cidr_block         = var.vpc_cidr_block
  private_subnets    = var.vpc_private_subnets
  public_subnets     = var.vpc_public_subnets
}

# module security
module "security" {
  source         = "./modules/security"
  region         = var.region
  vpc_id         = module.network.vpc_id
  workstation_ip = var.workstation_ip

}

# module bastion
module "bastion" {
  source                = "./modules/bastion"
  region                = var.region
  bastion_ami           = data.aws_ami.ubuntu-ami.id
  bastion_instance_type = var.bastion_instance_type
  key_name              = aws_key_pair.lab-key-pair.key_name
  subnet_id             = module.network.public_subnets[0]
  bastion_vpc_sg_id     = module.security.bastion_sg_id


}

# module storage
module "storage" {
  source = "./modules/storage"

  region                   = var.region
  mongo-instance-type      = var.mongodb_instance_type
  mongo-instance-ami       = data.aws_ami.ubuntu-ami.id
  key_name                 = aws_key_pair.lab-key-pair.key_name
  subnet_id                = module.network.private_subnets[0]
  mongo-instance-vpc-sg-id = module.security.mongodb_sg_id

}

# module application
module "application" {
  source = "./modules/application"

  region          = var.region
  instance_type   = var.application_instance_type
  vpc_id          = module.network.vpc_id
  ami             = data.aws_ami.ubuntu-ami.id
  key_name        = aws_key_pair.lab-key-pair.key_name
  alb_sg_id       = module.security.alb_sg_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  webserver_sg_id = module.security.application_sg_id
  mongodb_ip      = module.storage.mongo_instance_private_ip
  asg_desired     = 3
  asg_min_size    = 1
  asg_max_size    = 3
}
