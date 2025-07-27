resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}



resource "aws_iam_role" "node_role" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

module "cert_manager_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                       = "5.2.0"
  role_name                     = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = var.hosted_zone
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_oidc_provider
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
  tags = local.tags
}

## External DNS IRSA

module "external_dns_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                       = "5.2.0"
  role_name                     = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = var.hosted_zone
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_oidc_provider
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
  tags = local.tags
}