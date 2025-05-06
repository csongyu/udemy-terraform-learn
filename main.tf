provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.environment}-vpc"
  }
}

module "my-subnet" {
  source                 = "./modules/subnet"
  vpc_id                 = aws_vpc.my-vpc.id
  subnet_cidr_block      = var.subnet_cidr_block
  availability_zone      = var.availability_zone
  environment            = var.environment
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
}

module "my-webserver" {
  source            = "./modules/webserver"
  vpc_id            = aws_vpc.my-vpc.id
  environment       = var.environment
  public_key_path   = var.public_key_path
  subnet_id         = module.my-subnet.subnet-id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
}
