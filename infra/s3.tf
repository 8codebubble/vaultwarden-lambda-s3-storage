provider "aws" {
  region = "us-east-1"
}

# Define bucket name as a variable
variable "bucket_name" {
  default = "vaultwarden-backup-bucket"
}

# Create an S3 bucket
resource "aws_s3_bucket" "vaultwarden_bucket" {
  bucket = var.bucket_name
}

# Enable versioning for object tracking
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.vaultwarden_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Apply server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.vaultwarden_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Restrict public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.vaultwarden_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.vaultwarden_bucket.bucket
}

