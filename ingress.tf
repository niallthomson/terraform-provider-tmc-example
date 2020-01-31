resource "helm_release" "nginx_ingress" {

  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  chart      = "stable/nginx-ingress"
  version    = "1.29.5"

  provisioner "local-exec" {
    command = "sleep 30"
  }
}