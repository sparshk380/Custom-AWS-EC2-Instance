output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2-instance.public_ip
}

output "instance_public_dns" {
  value       = aws_instance.ec2-instance.public_dns
  description = "Public DNS of the EC2 instance"
}