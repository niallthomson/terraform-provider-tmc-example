resource "kubernetes_secret" "iam_secret" {
  metadata {
    name      = "aws-iam"
    namespace = "certmanager"
  }

  data = {
    access_key        = "${aws_iam_access_key.key.id}"
    secret_access_key = "${aws_iam_access_key.key.secret}"
  }

  type = "Opaque"
}

resource "kubernetes_job" "certmanager_prereq" {
  metadata {
    name      = "certmanager-prereq"
    namespace = "kube-system"
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "run"
          image   = "bitnami/kubectl"
          command = ["kubectl", "apply", "--validate=false", "-f", "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml"]
        }

        restart_policy                  = "Never"
        service_account_name            = "${kubernetes_service_account.helm.metadata.0.name}"
        automount_service_account_token = true
      }
    }
    backoff_limit = 4
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "template_file" "issuers" {
  template = "${file("${path.module}/templates/issuer.yml")}"

  vars {
    accessKey = "${aws_iam_access_key.key.id}"
    acmeEmail = "${var.acme_email}"
  }
}

resource "kubernetes_config_map" "issuer_config_map" {
  metadata {
    name      = "issuer-map"
    namespace = "kube-system"
  }

  data = {
    "issuer.yml" = "${data.template_file.issuers.rendered}"
  }
}

resource "kubernetes_job" "certmanager_issuer" {

  depends_on = [
    "kubernetes_job.certmanager_prereq",
    "kubernetes_secret.iam_secret"
  ]

  metadata {
    name      = "certmanager-issuer"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "run"
          image   = "bitnami/kubectl"
          command = ["kubectl", "apply", "--validate=false", "-f", "/var/issuer/issuer.yml"]

          volume_mount {
            mount_path = "/var/issuer"
            name = "issuer"
          }
        }

        volume {
          name = "issuer"
          config_map {
            name = "${kubernetes_config_map.issuer_config_map.metadata.0.name}"
          }
        }

        restart_policy                  = "Never"
        service_account_name            = "${kubernetes_service_account.helm.metadata.0.name}"
        automount_service_account_token = true
      }
    }
    backoff_limit = 4
  }
}

resource "helm_repository" "jetstack" {
  name = "jetstack"
  url = "https://charts.jetstack.io"
}

resource "helm_release" "certmanager" {

  depends_on = [
    "kubernetes_job.certmanager_prereq", 
  ]

  name       = "certmanager"
  namespace  = "certmanager"
  repository = "${helm_repository.jetstack.name}"
  chart      = "cert-manager"
  version    = "v0.13.0"

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "ingressShim.defaultACMEChallengeType"
    value = "dns01"
  }

  set {
    name  = "ingressShim.defaultACMEDNS01ChallengeProvider"
    value = "route53"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}