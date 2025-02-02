# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# VPC Configuration
resource "aws_vpc" "datathon_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "datathon-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.datathon_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "datathon-public-subnet"
  }
}

# S3 Bucket for Data Storage
resource "aws_s3_bucket" "datathon_bucket" {
  bucket = "chevron-datathon-2025-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.datathon_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker-datathon-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for SageMaker
resource "aws_iam_role_policy" "sagemaker_policy" {
  name = "sagemaker-datathon-policy"
  role = aws_iam_role.sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.datathon_bucket.arn,
          "${aws_s3_bucket.datathon_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sagemaker:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Security Group for SageMaker
resource "aws_security_group" "sagemaker_sg" {
  name        = "sagemaker-sg"
  description = "Security group for SageMaker notebook instance"
  vpc_id      = aws_vpc.datathon_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "sagemaker-sg"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.datathon_vpc.id

  tags = {
    Name = "datathon-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.datathon_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "datathon-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "datathon_notebook" {
  name          = "datathon-notebook"
  role_arn      = aws_iam_role.sagemaker_role.arn
  instance_type = "ml.t3.medium"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sagemaker_sg.id]
  
  tags = {
    Name = "datathon-notebook"
  }
}


# Outputs
output "notebook_url" {
  value = aws_sagemaker_notebook_instance.datathon_notebook.url
}

output "s3_bucket" {
  value = aws_s3_bucket.datathon_bucket.bucket
}