resource "helm_repository" "wavefront" {
  name = "wavefront"
  url = "https://wavefronthq.github.io/helm/"
}

resource "helm_release" "wavefront" {

  count = "${var.wavefront_token == "" ? 0 : 1}"

  name       = "wavefront"
  namespace  = "wavefront"
  repository = "${helm_repository.wavefront.name}"
  chart      = "wavefront"
  version    = "1.1.5"

  set {
    name  = "wavefront.url"
    value = "${var.wavefront_url}"
  }

  set {
    name  = "wavefront.token"
    value = "${var.wavefront_token}"
  }

  set {
    name  = "clusterName"
    value = "${tmc_cluster.tester.name}"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}