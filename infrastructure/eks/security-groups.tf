# Security Group for EKS worker nodes
resource "aws_security_group" "eks_workers" {
  name        = "${var.cluster_name}-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Control Plane to Node Communication (EKS Required)
  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Restricted to VPC
    description = "Allow VPC CIDR inbound traffic to EKS instances"
  }

  # Release all egress (with monitoring via Flow Logs)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-worker-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}