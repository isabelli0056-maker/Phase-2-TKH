provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "vulnerable_vault" {
  bucket = "tkh-exposed-vault-${random_id.id.hex}"
}

resource "random_id" "id" {
  byte_length = 4
}

# 1. Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "vault_public_block" {
  bucket                  = aws_s3_bucket.vulnerable_vault.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Enable Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_encryption" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Enable Bucket Versioning
resource "aws_s3_bucket_versioning" "vault_versioning" {
  bucket = aws_s3_bucket.vulnerable_vault.id
  versioning_configuration {
    status = "Enabled"
  }
}