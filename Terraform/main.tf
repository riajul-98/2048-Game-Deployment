module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  route_table_cidr   = var.route_table_cidr
}

module "EKS" {
  source = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn = module.iam.node_role_arn
  instance_types = var.instance_types
}

module "iam" {
  source = "./modules/iam"
}