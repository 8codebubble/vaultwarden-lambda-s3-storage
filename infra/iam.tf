provider "aws" {
  region = "us-east-1"
}

# Create IAM user for Lambda deployment
resource "aws_iam_user" "lambda_deployer" {
  name = "vaultwarden_lambda_deployer"
}

# Attach AWSLambdaFullAccess policy
resource "aws_iam_user_policy_attachment" "lambda_policy" {
  user       = aws_iam_user.lambda_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

# Attach AmazonS3FullAccess policy (for Litestream backups)
resource "aws_iam_user_policy_attachment" "s3_policy" {
  user       = aws_iam_user.lambda_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Generate IAM access keys for GitHub Actions
resource "aws_iam_access_key" "lambda_keys" {
  user = aws_iam_user.lambda_deployer.name
}

# Output IAM credentials (store securely in GitHub Secrets)
output "aws_access_key_id" {
  value = aws_iam_access_key.lambda_keys.id
  sensitive = true
}

output "aws_secret_access_key" {
  value = aws_iam_access_key.lambda_keys.secret
  sensitive = true
}

