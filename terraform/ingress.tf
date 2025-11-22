# ---------------------------
# Helm Provider (uses kubeconfig)
# ---------------------------


# ---------------------------
# Install NGINX Ingress via Helm
# ---------------------------
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"   # stable & compatible with EKS 1.26+

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    file("${path.module}/ingress-nginx-values.yaml")
  ]
}

# ---------------------------
# Get the AWS NLB hostname
# ---------------------------
data "kubernetes_service" "ingress_nginx" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

output "ingress_nlb_hostname" {
  value = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
}
