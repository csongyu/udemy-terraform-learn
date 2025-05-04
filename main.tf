provider "aws" {
  region = "us-west-2"
}

variable "vpc_cidr_block" {

}

variable "subnet_cidr_block" {

}

variable "availability_zone" {

}

variable "environment" {

}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.environment}-vpc"
  }
}

resource "aws_subnet" "my-subnet-1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.environment}-subnet-1"
  }
}
