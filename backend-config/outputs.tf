output "s3_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for locking"
  value       = aws_dynamodb_table.tf_lock.name
}