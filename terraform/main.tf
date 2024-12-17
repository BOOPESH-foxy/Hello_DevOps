provider "aws" {
  region = "ap-south-1"  # Mumbai region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

#subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-subnet"
  }
}

#internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}

#EC2 Instance for Backend
resource "aws_instance" "backend" {
  ami               = "ami-0e306788ff2473ccb"  # Latest Amazon Linux 2 AMI
  instance_type     = var.instance_type
  key_name          = var.key_name
  availability_zone = "ap-south-1a"
  subnet_id         = aws_subnet.public_subnet.id

  tags = {
    Name = "backend-instance"
  }
}

#S3 Bucket for Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.frontend_bucket_name}-${var.unique_suffix}"

  tags = {
    Name = "frontend-static-site"
  }
}

#Policy for Public Access
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id  # Correct reference

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",  # Allow everyone to access
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"  # Correct reference
      }
    ]
  })
}

#Static Website Hosting
resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id  # Correct reference

  index_document {
    suffix = "index.html"
  }
}

#Disabling Block Public Access
resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket = aws_s3_bucket.frontend_bucket.id  # Correct reference

  block_public_acls          = false
  block_public_policy        = false
  ignore_public_acls         = false
  restrict_public_buckets    = false
}
