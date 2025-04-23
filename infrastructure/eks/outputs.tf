output "cluster_security_group_id" {
  description = "Cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_role_arn" {
  description = "IAM Role ARN of Nodes"
  value       = module.eks.eks_managed_node_groups["main"].iam_role_arn
}

output "cluster_endpoint" {
  description = "Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
