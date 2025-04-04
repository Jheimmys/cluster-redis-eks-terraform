resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = var.prometheus_version
  values     = [file("${path.module}/../../monitoring/prometheus.yaml")]

  depends_on = [module.eks] # Wait for the EKS to be ready     
}