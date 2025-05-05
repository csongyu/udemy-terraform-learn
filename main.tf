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

# variable "my_cidr_ipv4" {
# }

# resource "aws_security_group" "my-security-group" {
#   name   = "my-security-group"
#   vpc_id = aws_vpc.my-vpc.id
#   tags = {
#     Name = "${var.environment}-security-group"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_myself_ssh_ipv4" {
#   security_group_id = aws_security_group.my-security-group.id
#   cidr_ipv4         = var.my_cidr_ipv4
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_all_http_ipv4" {
#   security_group_id = aws_security_group.my-security-group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.my-security-group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1"
# }

resource "aws_default_security_group" "default-security-group" {
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.my_cidr_ipv4]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-default-security-group"
  }
}

data "aws_ami" "latest-amazon-linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "amazon-linux-ami-id" {
  value = data.aws_ami.latest-amazon-linux-ami.id
}

variable "public_key_path" {
}

resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "aws-ec2-key-pair"
  public_key = file(var.public_key_path)
}

variable "instance_type" {
}

variable "private_key_path" {
}

resource "aws_instance" "my-nginx" {
  ami           = data.aws_ami.latest-amazon-linux-ami.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.my-subnet-1.id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_default_security_group.default-security-group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key-pair.key_name

  # user_data                   = file("entry-script.sh")
  # user_data_replace_on_change = true

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "entry-script.sh"
    destination = "/home/ec2-user/entry-script.sh"
  }

  provisioner "remote-exec" {
    script = file("entry-script.sh")
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > local-exec.txt"
  }

  tags = {
    Name = "${var.environment}-nginx"
  }
}

output "ec2-public-ip" {
  value = aws_instance.my-nginx.public_ip
}
