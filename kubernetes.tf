provider "kubernetes" {
  host                   = "${data.tmc_kubeconfig.kubeconfig.server}"

  client_certificate     = "${base64decode(data.tmc_kubeconfig.kubeconfig.client_certificate)}"
  client_key             = "${base64decode(data.tmc_kubeconfig.kubeconfig.client_key)}"
  cluster_ca_certificate = "${base64decode(data.tmc_kubeconfig.kubeconfig.cluster_ca_certificate)}"
}

resource "kubernetes_config_map" "example" {
  metadata {
    name = "my-config2"
  }

  data = {
    api_host             = "myhost:443"
    db_host              = "dbhost:5432"
  }
}