terraform {
  backend "s3" {
    key            = "cluster-redis/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}