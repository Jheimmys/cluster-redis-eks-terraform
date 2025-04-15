variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1" # I chose this region because of the price.
}

#cluster EKS
variable "cluster_name" {
  description = "Name of the cluster eks"
  type        = string
  default     = "redis-eks-cluster"
}

variable "cluster_version" {
  description = "Version of the cluster eks"
  type        = string
  default     = "1.32"
}

#VPC
variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "redis-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.10.0.0/16"
}

variable "flow_log_interval" {
  description = "Flow logs aggregation interval in seconds"
  type        = number
  default     = 60 # 1 minute
}

#Redis
variable "redis_password" {
  description = "Cluster redis secret"
  type        = string
  default     = "testeredis"
}

variable "redis_version" {
  description = "Cluster Redis version chart OCI"
  type        = string
  default     = "11.4.6"
}

#Grafana
variable "grafana_password" {
  description = "Grafana Secret"
  type        = string
  default     = "testegrafana"
}

variable "grafana_user" {
  description = "Grafana User"
  type        = string
  default     = "admin"
}

variable "grafana_version" {
  description = "Grafana Version Chart"
  type        = string
  default     = "8.10.3"
}

#Prometheus
variable "prometheus_version" {
  description = "Prometheus Version Chart"
  type        = string
  default     = "69.7.2"
}