provider "aws" {
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key

  s3_use_path_style           = true

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = "http://localhost:4566"
    sqs = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = var.bucket

  tags = {
    Name        = "Desafio"
    Environment = "Dev"
  }
}

resource "aws_sqs_queue" "terraform_queue" {
  name                        = var.aws_sqs_queue
}