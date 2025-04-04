module "vpc" {
  source            = "./vpc"
  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  flow_log_interval = var.flow_log_interval
}

module "eks" {
  source             = "./eks"
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  vpc_cidr           = var.vpc_cidr
  aws_region         = var.aws_region
  redis_password     = var.redis_password
  redis_version      = var.redis_version
  grafana_password   = var.grafana_password
  grafana_user       = var.grafana_user
  grafana_version    = var.grafana_version
  prometheus_version = var.prometheus_version

}