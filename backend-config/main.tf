# S3 Bucket for Terraform State
resource "aws_s3_bucket" "tf_state" {
  bucket        = "tfstate-cluster-redis-jheimmys"
  force_destroy = true # just in dev environment
  tags = {
    Purpose = "TerraformState"
  }
}

# Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}