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

resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# resource "aws_route_table" "my-route-table" {
#   vpc_id = aws_vpc.my-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my-internet-gateway.id
#   }
#   tags = {
#     Name = "${var.environment}-route-table"
#   }
# }

# resource "aws_route_table_association" "my-association" {
#   subnet_id      = aws_subnet.my-subnet-1.id
#   route_table_id = aws_route_table.my-route-table.id
# }

resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }
  tags = {
    Name = "${var.environment}-main-route-table"
  }
}
