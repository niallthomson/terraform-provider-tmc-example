data "aws_route53_zone" "selected" {
  zone_id      = "${var.root_hosted_zone_id}"
}

data "template_file" "dns_config" {
  template = "${file("${path.module}/templates/external-dns-values.yml")}"

  vars {
    accessKey = "${aws_iam_access_key.key.id}"
    secretKey = "${aws_iam_access_key.key.secret}"
  }
}

resource "aws_route53_record" "weighted" {
    zone_id = "${data.aws_route53_zone.selected.id}"
    name = "nginx.${data.aws_route53_zone.selected.name}"
    type = "CNAME"
    ttl = "60"
    set_identifier = "${var.id}-${local.region_short}"
    health_check_id = "${aws_route53_health_check.health.id}"

    records = [
        "${data.kubernetes_service.nginx_ingress.load_balancer_ingress.0.hostname}"
    ]
    weighted_routing_policy  {
        weight = 1
    }
}

resource "aws_route53_record" "basic" {
    zone_id = "${data.aws_route53_zone.selected.id}"
    name = "nginx.${local.region_short}.${data.aws_route53_zone.selected.name}"
    type = "CNAME"
    ttl = "60"
    records = [
        "${data.kubernetes_service.nginx_ingress.load_balancer_ingress.0.hostname}"
    ]
}

resource "aws_route53_health_check" "health" {
  fqdn              = "nginx.${local.region_short}.${data.aws_route53_zone.selected.name}"
  type              = "HTTPS"
  port              = "443"
  resource_path     = "/"  # Make a request to https://api-*.example.com/
  failure_threshold = "5"
  request_interval  = "30"
}