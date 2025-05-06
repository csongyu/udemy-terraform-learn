output "ec2-public-ip" {
  value = aws_instance.my-nginx.public_ip
}