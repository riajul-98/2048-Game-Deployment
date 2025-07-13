resource "aws_eks_cluster" "project_cluster" {
    name = local.cluster_name
    vpc_config {
      subnet_ids = var.private_subnet_ids
    }
    role_arn = var.cluster_role_arn
    tags = local.tags
    region = local.region
}

resource "aws_eks_node_group" "project_node_group" {
  cluster_name = aws_eks_cluster.project_cluster.name
  subnet_ids = var.private_subnet_ids
  node_role_arn = var.node_role_arn
  instance_types = var.instance_types
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }
  tags = local.tags
}