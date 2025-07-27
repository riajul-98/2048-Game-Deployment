resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  create_namespace = true
  namespace        = "nginx-ingress"
  depends_on = [ var.node_group ]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]

  values = [
    "${file("../helm-values/cert-manager.yaml")}"
  ]
  depends_on = [ helm_release.nginx ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  create_namespace = true
  namespace        = "external-dns"

  set = [
    {
      name  = "wait-for"
      value = var.external_dns_irsa_role_arn
    }
  ]

  values = [
    "${file("../helm-values/external-dns.yaml")}"
  ]
  depends_on = [ helm_release.nginx ]
}

resource "null_resource" "apply_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${var.cluster_name}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [ helm_release.nginx ]
}

resource "null_resource" "apply_cert_issuer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ../cert-man/issuer.yaml"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [ null_resource.apply_kubeconfig ]
}


resource "helm_release" "argocd_deploy" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  # timeout          = "600"
  namespace        = "argo-cd"
  create_namespace = true

  values = [
    "${file("../helm-values/argocd.yaml")}"
  ]

  depends_on = [ helm_release.external_dns, helm_release.cert-manager, helm_release.nginx, null_resource.apply_cert_issuer ]
}