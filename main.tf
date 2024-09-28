resource "aws_key_pair" "local_key" {
  key_name   = "local-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sg_1" {
  name        = "tf-sg"
  description = "Allow SSH and HTTP, HTTPS"

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2-instance" {
  ami             = "ami-005fc0f236362e99f"
  instance_type   = "t2.medium"
  key_name        = aws_key_pair.local_key.key_name
  security_groups = [aws_security_group.sg_1.name]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  user_data = <<-EOF
        #!/bin/bash
        curl -sfL https://get.k3s.io | sh -
        sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
        https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt-get update -y
        sudo apt-get install fontconfig openjdk-17-jre -y
        sudo apt-get install jenkins -y
        EOF

  tags = {
    Name = "EC2-Instance-T2.MEDIUM"
  }
}