output "nginx_ingress_endpoint" {
  value = "${data.kubernetes_service.nginx_ingress.load_balancer_ingress.0.hostname}"
}

output "kubeconfig" {
  value = "${data.tmc_kubeconfig.kubeconfig.content}"
}