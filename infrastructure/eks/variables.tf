variable "cluster_name" {
  description = "Name of the cluster eks"
  type        = string
}

variable "cluster_version" {
  description = "Version of the cluster eks"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets IDs"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block for traffic restriction"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "redis_password" {
  description = "Cluster redis secret"
  type        = string
}

variable "grafana_password" {
  description = "Grafana secret"
  type        = string
}

variable "grafana_user" {
  description = "Grafana user"
  type        = string
}

variable "redis_version" {
  description = "Cluster redis version chart OCI"
  type        = string
}

variable "grafana_version" {
  description = "Grafana version chart"
  type        = string
}

variable "prometheus_version" {
  description = "Prometheus version chart"
  type        = string
}