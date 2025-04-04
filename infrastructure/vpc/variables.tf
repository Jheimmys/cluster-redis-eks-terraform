variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "flow_log_interval" {
  description = "Flow logs aggregation interval in seconds"
  type        = number
}