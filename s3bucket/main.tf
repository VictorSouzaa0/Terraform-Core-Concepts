terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"    
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#Create S3 Bucket
resource "aws_s3_bucket" "first-bucket" {
  bucket = "victorsouza-20050948-bucket"

  tags = {
    Name = "My bucket 2.0"
    Enviroment = "Dev"
  }
}