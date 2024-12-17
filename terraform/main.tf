provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "devops-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "devops-igw"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-0e306788ff2473ccb" # Latest Amazon Linux 2 AMI in ap-south-1
  instance_type = "t2.micro"
  key_name      = "hello_devops"
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "backend-instance"
  }
}
