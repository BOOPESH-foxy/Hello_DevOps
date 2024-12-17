# EC2 Instance - Backend
resource "aws_instance" "backend" {
  ami               = "ami-0e306788ff2473ccb"  # Amazon Linux 2 AMI
  instance_type     = var.instance_type
  key_name          = var.key_name
  availability_zone = "ap-south-1a"
  subnet_id         = aws_subnet.public_subnet.id

  # User data to install Docker and backend setup
  user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              sudo yum install -y git
              cd /home/ec2-user
              git clone https://github.com/BOOPESH-foxy/Hello_DevOps.git
              cd Hello_DevOps/backend
              docker build -t status-image .
              docker run -d -p 3000:3000 status-image
              EOT

  tags = {
    Name = "backend-instance"
  }

  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}

resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow HTTP and SSH traffic for backend"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    description = "Backend API (HTTP)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
