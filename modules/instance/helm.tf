resource "kubernetes_service_account" "helm" {
  metadata {
    name = "helm"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "helm" {
  metadata {
    name = "${kubernetes_service_account.helm.metadata.0.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "${kubernetes_service_account.helm.metadata.0.name}"
    namespace = "kube-system"

    # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/204
    api_group = ""
  }
}

provider "helm" {
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "${kubernetes_cluster_role_binding.helm.metadata.0.name}"

  version = "~> 0.10.0"

  kubernetes {
    host                   = "${data.tmc_kubeconfig.kubeconfig.server}"

    client_certificate     = "${base64decode(data.tmc_kubeconfig.kubeconfig.client_certificate)}"
    client_key             = "${base64decode(data.tmc_kubeconfig.kubeconfig.client_key)}"
    cluster_ca_certificate = "${base64decode(data.tmc_kubeconfig.kubeconfig.cluster_ca_certificate)}"
  }
}