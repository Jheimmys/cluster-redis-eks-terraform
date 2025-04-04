
# Infrastructure Setup Documentation

## Prerequisites

Before initializing the infrastructure, ensure that you have the following tools installed:

- **Terraform** (v1.11.0+)
- **AWS CLI** (Latest version)
- **kubectl** (v1.32.2+)
- **Helm** (v3.17.1+)
- **K9s** (optional - v0.40.5+)
- **eksctl** (optional - 0.205.0+)

## Infrastructure Initialization Process

### 1. Configure AWS CLI

First, configure the AWS CLI with the credentials for the user `unzer` that was created in AWS account for the project.

Run the following command to set up AWS credentials:

```bash
aws configure
```

### 2. Initialize Terraform Backend

Navigate to the `backend-config` folder and run the following Terraform commands to initialize and apply the configuration for creating the S3 bucket (to store the state) and the DynamoDB table (for state locking).

```bash
cd backend-config
terraform init
terraform apply
```

Once the bucket and DynamoDB table are created, proceed to the next steps.

`Outputs:`

```bash
dynamodb_table_name = "terraform-lock"
s3_bucket_name = "tfstate-cluster-redis-jheimmys"
```

Copy and paste the command below into the terminal:

```bash
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
```

### 3. Initialize and Apply Terraform Infrastructure

Now, navigate to the `infrastructure` folder and run the following commands to initialize Terraform with the backend configuration:

```bash
terraform init -backend-config="bucket=$BUCKET_NAME"
```
Now, run the Terraform plan and apply commands:

```bash
terraform plan
terraform apply
```
### 4. Test Access cluster

```bash
aws eks update-kubeconfig --name redis-eks-cluster --region us-east-1
kubectl get nodes
```
---

## Prometheus Setup

In the `monitoring` folder will be the `prometheus.yaml` configuration file used to install the Prometheus Operator (ServiceMonitor)

Prometheus installation is being done `automatically` by terraform, `helm-release` feature.

> **Note:** The namespace monitoring was previoulsy created by terraform.

---

## Redis Cluster Installation (Helm)

In the `redis-cluster` folder will be the `values.yaml` configuration file used to install the redis-cluster.

Redis-Cluster installation is being done `automatically` by terraform, `helm-release` feature.

> **Note:** The namespace redis was previoulsy created by terraform.

> **Note:** The secret for redis was previoulsy created by terraform.

---

## Test Redis Cluster

After the Redis pods are running, test the cluster by running the following commands:

1. Set the `REDIS_PASSWORD` environment variable:

```bash
export REDIS_PASSWORD="password"
```

2. Check the Redis cluster status:

```bash
kubectl exec -it redis-cluster-0 -n redis -- redis-cli -a $REDIS_PASSWORD --cluster check 127.0.0.1:6379
```

3. Set a test key-value pair:

```bash
kubectl exec -it redis-cluster-0 -n redis -- redis-cli -c
set test_key "test_value"
```

4. In another pod, retrieve the value:

```bash
kubectl exec -it redis-cluster-1 -n redis -- redis-cli -a $REDIS_PASSWORD get test_key
```

It should return `test_value`.

---

## Monitoring - Grafana Setup

In the `monitoring` folder will be the `grafana.yaml` configuration file used to install the Grafana.

Grafana installation is being done `automatically` by terraform, `helm-release` feature.

> **Note:** The secret for Grafana was previoulsy created by terraform.

You can access Grafana via port-forward (cluster IP) or from a machine inside AWS on the same network as the cluster.

> **Note:** Import dashboard 21914 on Grafana to visualize monitoring cluster-redis.

---

## Environment Details

- **Region**: `us-east-1`
- **Cluster Name**: `redis-eks-cluster`
- **Namespaces**:
  - `redis`: For the Redis cluster
  - `monitoring`: For monitoring tools (Prometheus, Grafana)
- **VPC**: A new VPC is created for the cluster with 2 public subnets and 2 private subnets.
- **Availability Zones**: The cluster spans across 2 different Availability Zones for higher availability.

---

## Important Links

- **Redis Cluster**: https://artifacthub.io/packages/helm/bitnami/redis-cluster
- **Grafana Helm chart**: https://github.com/grafana/helm-charts/tree/main/charts/grafana
- **AWS-Auth Terraform**: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/aws-auth
- **EKS Module Terraform**: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/20.33.1?utm_content=documentLink&utm_medium=Visual+Studio+Code&utm_source=terraform-ls
- **VPC Module Terraform**: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.19.0?utm_content=documentLink&utm_medium=Visual+Studio+Code&utm_source=terraform-ls

---