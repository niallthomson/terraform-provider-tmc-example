data "template_file" "dns_config" {
  template = "${file("${path.module}/templates/external-dns-values.yml")}"

  vars {
    accessKey = "${aws_iam_access_key.key.id}"
    secretKey = "${aws_iam_access_key.key.secret}"
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "external-dns"
  chart      = "stable/external-dns"
  version    = "2.15.3"

  values = ["${data.template_file.dns_config.rendered}"]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}