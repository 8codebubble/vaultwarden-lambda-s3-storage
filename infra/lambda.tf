# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "vaultwarden_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Basic Lambda Permissions
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Policy for S3 Access (Updated Bucket Name)
resource "aws_iam_policy" "s3_access_policy" {
  name        = "VaultwardenLambdaS3Access"
  description = "Allows Lambda to access S3 for backups"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::vaultwarden-litestream-bucket/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Archive Lambda Function Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Create Lambda Function
resource "aws_lambda_function" "vaultwarden_lambda" {
  function_name = "vaultwarden"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Updated S3 Bucket for Backups
resource "aws_s3_bucket" "vaultwarden_backup" {
  bucket = "vaultwarden-litestream-bucket"
}

# S3 Bucket Policy for Secure Access (Updated Bucket Name)
resource "aws_s3_bucket_policy" "vaultwarden_s3_policy" {
  bucket = aws_s3_bucket.vaultwarden_backup.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource  = "arn:aws:s3:::vaultwarden-litestream-bucket/*",
        Principal = {
          AWS = aws_iam_role.lambda_execution_role.arn
        }
      }
    ]
  })
}
