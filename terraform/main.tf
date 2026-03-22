terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket to store pipeline outputs
resource "aws_s3_bucket" "pipeline_output" {
  bucket = "financial-pipeline-output-${var.account_id}"

  tags = {
    Name        = "financial-pipeline-output"
    Environment = "dev"
    Project     = "financial-data-pipeline"
  }
}

resource "aws_s3_bucket_versioning" "pipeline_output" {
  bucket = aws_s3_bucket.pipeline_output.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Security group for EC2
resource "aws_security_group" "airflow_sg" {
  name        = "airflow-sg"
  description = "Security group for Airflow EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "airflow-sg"
  }
}

# EC2 instance
resource "aws_instance" "airflow" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.airflow_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose-plugin git
    sudo systemctl start docker
    sudo usermod -aG docker ubuntu
    cd /home/ubuntu
    git clone https://github.com/AnushkaJoshi14/financial-data-pipeline.git
    cd financial-data-pipeline
    sudo docker compose up -d
  EOF

  tags = {
    Name    = "airflow-instance"
    Project = "financial-data-pipeline"
  }
}