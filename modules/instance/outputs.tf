output "nginx_ingress_endpoint" {
  value = "${data.kubernetes_service.nginx_ingress.load_balancer_ingress.0.hostname}"
}

output "kubeconfig" {
  value     = "${data.tmc_kubeconfig.kubeconfig.content}"
  sensitive = true
}

output "rds_cluster_id" {
  value = "${aws_rds_cluster.cluster.id}"
}

output "rds_endpoint" {
  value = "${aws_rds_cluster_instance.instance.endpoint}"
}