# variable "region" {
#   description = "The AWS region"
#   default     = "ap-south-1"
# }

variable "unique_suffix" {
  description = "A unique identifier to make resource names globally unique"
  default     = "boo"
}

# EC2 Configuration
variable "instance_type" {
  description = "The type of EC2 instance to run the backend application"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair for SSH access to EC2"
  default     = "hello_devops"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "public_access_cidr" {
  description = "CIDR block for public access to EC2 instance"
  default     = "0.0.0.0/0"
}

variable "frontend_bucket_name" {
  description = "The name prefix for the S3 bucket hosting the frontend"
  default     = "devops-frontend"
}

# Monitoring
variable "alarm_threshold" {
  description = "CPU utilization threshold to trigger alarms"
  default     = 80
}
