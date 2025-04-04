variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1" # I chose this region because of the price.
}

variable "s3_bucket_name" {
  description = "Bucket name"
  type        = string
  default     = "tfstate-cluster-redis-jheimmys"
}