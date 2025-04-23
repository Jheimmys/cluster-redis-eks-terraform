resource "helm_release" "redis" {
  name      = "redis-cluster"
  namespace = "redis"
  chart     = "oci://registry-1.docker.io/bitnamicharts/redis-cluster"
  version   = var.redis_version
  values    = [file("${path.module}/../../redis-cluster/values.yaml")]

  depends_on = [module.eks, helm_release.prometheus] # Wait for the EKS and prometheus to be ready     
}