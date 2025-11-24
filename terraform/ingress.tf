provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.14.0"

  create_namespace = true

  set = [
    {
      name  = "controller.publishService.enabled"
      value = "true"
    }
  ]
}

data "kubernetes_service" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

output "ingress_controller_ip" {
    value = "http://${data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname}"
  description = "External IP of ingress-nginx controller"
}

