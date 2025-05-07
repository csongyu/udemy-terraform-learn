terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    region = "us-west-2"
    bucket = "chensongyu-terraform-state-bucket"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs            = [var.availability_zone]
  public_subnets = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.environment}-subnet-1"
  }

  tags = {
    Name = "${var.environment}-vpc"
  }
}

module "my-webserver" {
  source            = "./modules/webserver"
  vpc_id            = module.vpc.vpc_id
  environment       = var.environment
  public_key_path   = var.public_key_path
  subnet_id         = module.vpc.public_subnets[0]
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
}
