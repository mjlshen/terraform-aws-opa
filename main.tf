terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "debug" {
  triggers = {
    test = aws_s3_account_public_access_block.standard.id
  }
}

resource "aws_s3_account_public_access_block" "standard" {
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket" "test" {
  bucket = "435257025969-test-bucket"
  acl    = "public-read"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    apm_id      = "007"
    dept        = "secret_service"
    environment = "research"
  }
}

resource "aws_secretsmanager_secret" "example" {
  name = "example"
}

resource "aws_secretsmanager_secret_version" "first" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = "sUp3rs3cr3t"
}

data "aws_secretsmanager_secret_version" "second" {
  secret_id = aws_secretsmanager_secret.example.id
}