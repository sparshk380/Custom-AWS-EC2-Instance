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
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        helm repo add jenkins https://charts.jenkins.io
        helm repo update
        kubectl create namespace jenkins
        helm install jenkins jenkins/jenkins --namespace jenkins
        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
        helm repo update
        helm install nginx-ingress ingress-nginx/ingress-nginx --namespace jenkins --set controller.service.type=LoadBalancer
        EOF

  tags = {
    Name = "EC2-Instance-T2.MEDIUM"
  }
}
