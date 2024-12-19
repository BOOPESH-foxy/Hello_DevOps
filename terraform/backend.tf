
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "/aws/ec2/backend"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.backend.id
  }
}

# EC2 Instance - Backend
resource "aws_instance" "backend" {
  ami               = "ami-0e306788ff2473ccb"  
  instance_type     = var.instance_type
  key_name          = var.key_name
  availability_zone = "ap-south-1a"
  subnet_id         = aws_subnet.public_subnet.id

  user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              sudo yum install -y git
              sudo yum install -y aws-cfn-bootstrap
              sudo yum install -y amazon-cloudwatch-agent

              echo '{
                "agent": {
                  "metrics_collection_interval": 60,
                  "run_as_user": "root"
                },
                "metrics": {
                  "append_dimensions": {
                    "InstanceId": "${!instance_id}"
                  },
                  "aggregation_dimensions": [["InstanceId"]],
                  "metrics_collected": {
                    "CPU": {
                      "measurement": ["UsageIdle", "UsageUser", "UsageSystem"],
                      "metrics_collection_interval": 60
                    },
                    "Disk": {
                      "measurement": ["Used", "Free", "Total"],
                      "metrics_collection_interval": 60
                    },
                    "Memory": {
                      "measurement": ["MemUsed", "MemAvailable", "MemTotal"],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

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

# Security Group for Backend
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
