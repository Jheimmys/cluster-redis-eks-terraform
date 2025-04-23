resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = var.grafana_version
  values     = [file("${path.module}/../../monitoring/grafana.yaml")]

  depends_on = [module.eks] # Wait for the EKS to be ready     
}