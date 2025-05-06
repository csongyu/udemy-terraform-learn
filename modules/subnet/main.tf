resource "aws_subnet" "my-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.environment}-subnet-1"
  }
}

resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }
  tags = {
    Name = "${var.environment}-main-route-table"
  }
}
