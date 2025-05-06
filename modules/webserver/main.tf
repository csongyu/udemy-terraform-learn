resource "aws_default_security_group" "default-security-group" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_key_pair" "ssh-key-pair" {
  key_name   = "aws-ec2-key-pair"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "my-nginx" {
  ami           = data.aws_ami.latest-amazon-linux-ami.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = [aws_default_security_group.default-security-group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key-pair.key_name

  user_data                   = file("entry-script.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "${var.environment}-nginx"
  }
}
