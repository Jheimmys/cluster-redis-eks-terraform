module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version # Latest version
  cluster_endpoint_public_access           = true                # Just in dev, production false (use vpn for example)
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    main = {
      name           = "managed-node-group"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      capacity_type  = "ON_DEMAND"

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEKSClusterPolicy   = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      }

      vpc_security_group_ids = [aws_security_group.eks_workers.id]

      # EBS Volume
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20 #GB
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  # Enables critical addons for cluster operation
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true" # Scalability improvement
        }
      })
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.33.1"

  manage_aws_auth_configmap = false # Cluster being created for the first time - false (after creating the config_map set it to true on the next run)
  create_aws_auth_configmap = true  # Cluster being created for the first time - true (after creating the config_map set it to false on the next run)

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::692975265565:user/unzer"
      username = "unzer"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = ["692975265565"]
}

# Create namespace redis
resource "kubernetes_namespace" "redis" {
  metadata {
    annotations = {
      name = "redis"
    }
    name = "redis"
  }
  depends_on = [module.eks]
}

# Create namespace monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }
    name = "monitoring"
  }
  depends_on = [module.eks]
}

# Create secret cluster redis
resource "kubernetes_secret" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = "redis"
  }

  data = {
    "redis-password" = var.redis_password
  }
  depends_on = [module.eks]
}

# Create secret grafana
resource "kubernetes_secret" "grafana_secret" {
  metadata {
    name      = "grafana-secret"
    namespace = "monitoring"
  }

  data = {
    "grafana-password" = var.grafana_password
    "admin"            = var.grafana_user
  }
  depends_on = [module.eks]
}