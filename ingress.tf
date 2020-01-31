data "template_file" "nginx_config" {
  template = "${file("${path.module}/templates/nginx-ingress-values.yml")}"
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  chart      = "stable/nginx-ingress"
  version    = "1.29.5"

  values = ["${data.template_file.nginx_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name = "${helm_release.nginx_ingress.name}-controller"
    namespace = "${helm_release.nginx_ingress.namespace}"
  }
}