# Infrastructure Design Decisions

## 1. Remote State Terraform and Amazon S3

- **Choice**: I implemented remote state with locking, even though this is an individual environment, to demonstrate the full flow of an enterprise-ready implementation and because it is a mandatory practice in professional environments.

- **S3 Configuration**:
  - Versioning enabled to ensure that previous state versions can be retrieved if needed.
  - AES-256 encryption enabled to secure the state files.
  
- **DynamoDB**:
  - Used for atomic locking during Terraform apply to prevent concurrency issues.

## 2. Network Architecture

### VPC Module:
- **Choice**: I opted for the latest version of the VPC module to ensure compatibility with newer AWS services and to demonstrate the importance of keeping dependencies updated in production.
  
- **VPC Configuration**:
  - New, dedicated VPC for the EKS cluster with a /16 address space for scalability.
  - 4 subnets (2 private, 2 public) across 2 Availability Zones (AZs) for higher availability.
  - NAT Gateway enabled: Required for private subnets (ensure connectivity with AWS for example). I chose a single NAT Gateway to reduce costs, but in production, it’s better to use two NAT Gateways for redundancy (1 per AZ).
  - Tags configured for private and public subnets: Required for AWS Load Balancer Controller.
  - Flow Logs enabled: Configured for compliance and troubleshooting. Set to 60-second intervals to balance medium detection and cost. Integrated with CloudWatch for centralized analysis.

## 3. AWS Region Choice

- **Choice**: I selected `us-east-1` because it is the most economical AWS region, offering approximately 20% cost savings compared to `eu-central-1`.

## 4. EKS Security Group Design

- **Conscious Decision**: "I opted to allow all egress traffic to simplify the implementation of the challenge. However, in production, I would restrict this to essential ports and use VPC Endpoints to restrict the egress, with monitoring via VPC Flow Logs."
  
- **Commitment to Security**: "I maintained the restrictive ingress rules as per AWS documentation, showing attention to the minimum security requirements."

- **Readiness for Evolution**: "In a real environment, I would implement VPC Endpoints and network policies in Kubernetes as the next steps."

### Justification:
- **Trade-off**: For the scope of the challenge, I made a trade-off between security and agility. In production, I would implement more restrictive rules and VPC Endpoints.

## 5. EKS Cluster Configuration

### Node Groups:
- **Choice**: I used `t3.medium` instances with 2 vCPUs and 4GB RAM, which are suitable for medium workloads.
- **Auto Scaling**: Configured with 2-4 instances to handle varying loads automatically.
- **EBS Volumes**: I used encrypted `gp3` disks for data protection.

### Essential Add-ons:
- **AWS EBS CSI Driver**: Ensures support for persistent volumes.
- **VPC CNI**: Configured for native networking within the cluster.
- **CoreDNS and Kube-Proxy**: Standard Kubernetes components required for DNS resolution and internal communication within the cluster.

## 6. Redis Cluster Configuration

- **Design**: Configured a native Redis cluster with 6 nodes (3 masters and 3 replicas), ensuring high availability and scalability.
- **Persistence**: Enabled persistent volumes (PVCs) with a consistent storage class to protect data during pod restarts or failures.

### Probes and Resources:
- **Health Checks**: Configured liveness, readiness, and startup probes to guarantee that the Redis pods remain healthy.
- **Resource Requests and Limits**: Set to prevent overloading the Redis cluster and to maintain optimal performance.

## 7. CI/CD Strategy

### Zero Downtime for Redis Cluster:
- **Strategy**: Rolling updates in Kubernetes to update one node at a time, ensuring there is no downtime.
- **partition: 0**: Ensures that all pods are upgraded gradually, maintaining high availability and avoiding downtime during the upgrade.
- **Probes**: Configured liveness, readiness, and startup probes to ensure that only healthy nodes receive traffic.
- **Helm Orchestration**: Used Helm to manage releases in a controlled manner.
- **Pipeline**: Configured automatic rollback in case of failure.

## 8. CI/CD Pipeline in GitHub Actions

- **Pipeline Features**:
  - Pre-deployment checks.
  - Helm-based deployment with `--atomic --wait` to ensure the release is fully deployed before continuing.
  - Post-deployment validation and automatic rollback in case of failure.
  - Workflow structure and scripts organized in the `redis-cluster/scripts/` folder for modularity and maintainability.

## 9. Pre and Post-Upgrade Scripts

- **Scripts**: 
  - `pre-upgrade-check.sh` and `post-upgrade-check.sh` perform essential checks, including pinging the cluster, checking cluster state, verifying allocated slots, and testing read/write functionality.
  - These scripts help ensure the Redis cluster is in good condition before and after an upgrade, satisfying the requirement for zero downtime and continuous validation.

## 10. Terraform Infrastructure

- **Modules**:
  - I organized my Terraform modules for EKS, VPC, and backend configuration to be modular and reusable.