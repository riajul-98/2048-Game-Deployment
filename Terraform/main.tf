module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  route_table_cidr   = var.route_table_cidr
}

module "eks" {
  source             = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  instance_types     = var.instance_types
}

module "iam" {
  source            = "./modules/iam"
  hosted_zone       = var.hosted_zone
  eks_oidc_provider = module.eks.oidc_provider_arn
}

module "helm" {
  source                     = "./modules/helm"
  external_dns_irsa_role_arn = module.iam.external_dns_irsa_role_arn
  node_group = module.eks.node_group
  cluster_name = module.eks.cluster_name
}