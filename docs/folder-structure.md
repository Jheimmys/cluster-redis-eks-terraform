CLUSTER-REDIS-TERRAFORM-EKS/
├── .github/                            # GitHub Actions configuration
│   └── workflows/                      # Contains CI/CD workflow files
│       └── deploy-redis-cluster.yaml   # GitHub Actions workflow for Redis Cluster deployment
├── backend_config/                     # Terraform backend configuration
│   ├── main.tf                         # Defines backend storage (e.g., S3, remote state)
│   ├── outputs.tf                      # Defines output variables for backend
│   ├── provider.tf                     # Define AWS provider
│   └── variables.tf                    # Input variables for backend configuration
├── infrastructure/                     # Infrastructure as Code (IaC) using Terraform
│   ├── eks/                            # EKS (Elastic Kubernetes Service) setup
│   │   ├── kubernetes.tf               # Defines Kubernetes cluster configuration
│   │   ├── outputs.tf                  # Outputs related to the EKS cluster
│   │   ├── variables.tf                # Input variables for EKS configuration
│   │   ├── helm-grafana.tf             # Helm-release install grafana
│   │   ├── helm-prometheus.tf          # Helm-release install prometheus
│   │   ├── helm-redis.tf               # Helm-release install redis-cluster
│   │   ├── provider.tf                 # Define Kubernetes and Helm providers
│   │   └── security-groups.tf          # Security group rules for EKS resources
│   ├── vpc/                            # VPC (Virtual Private Cloud) setup
│   │   ├── main.tf                     # Defines VPC configuration
│   │   ├── outputs.tf                  # Outputs related to the VPC
│   │   └── variables.tf                # Input variables for VPC configuration
│   ├── main.tf                         # Root Terraform configuration
│   ├── backend.tf                      # Backend settings for storing Terraform state
│   ├── provider.tf                     # Define AWS provider
│   ├── outputs.tf                      # General output variables for infrastructure
│   └── variables.tf                    # General input variables for infrastructure
├── redis-cluster/                      # Redis Cluster Helm deployment configuration
│   ├── values.yaml                     # Helm values configuration for Redis Cluster
│   └── scripts/                        # Pre- and post-deployment validation scripts
│       ├── pre-upgrade-check.sh        # Checks Redis Cluster status before deployment
│       └── post-upgrade-check.sh       # Validates Redis Cluster state after deployment
├── monitoring/                         # Contain Monitoring file cluster-redis
│   ├── grafana.yaml                    # Helm values configuration Grafana
│   └── prometheus.yaml                 # Helm values configuration prometheus
├── docs/                               # Documentation of Project
│   ├── architecture-diagram.png        # Architecture diagram
│   ├── decisions.md                    # Technical decisions
│   └── folder-structure.md             # folder structure of project
└── README.md