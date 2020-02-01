variable "tmc_key" {}

variable "acme_email" {}

variable "root_hosted_zone_id" {}

variable "wavefront_token" {
  default = ""
}

variable "wavefront_url" {
  default = ""
}

provider "tmc" {
  api_key = "${var.tmc_key}"
}

resource "random_id" "id" {
  byte_length = 4
}

resource "tmc_cluster_group" "group" {
  name        = "bootcamp-group-${random_id.id.hex}"
  description = "Bootcamp group ${random_id.id.hex}"
}

resource "aws_rds_global_cluster" "global_cluster" {
  global_cluster_identifier = "bootcamp-group-${random_id.id.hex}"
}

module "first" {
  source = "./modules/instance"

  id                    = "${random_id.id.hex}"
  tmc_cluster_group     = "${tmc_cluster_group.group.name}"
  acme_email            = "${var.acme_email}"
  root_hosted_zone_id   = "${var.root_hosted_zone_id}"
  region                = "us-west-2"
  rds_global_cluster_id = "${aws_rds_global_cluster.global_cluster.id}"

  wavefront_token       = "${var.wavefront_token}"
  wavefront_url         = "${var.wavefront_url}"
}

module "second" {
  source = "./modules/instance"

  id                    = "${random_id.id.hex}"
  tmc_cluster_group     = "${tmc_cluster_group.group.name}"
  acme_email            = "${var.acme_email}"
  root_hosted_zone_id   = "${var.root_hosted_zone_id}"
  region                = "eu-west-1"
  rds_global_cluster_id = "${aws_rds_global_cluster.global_cluster.id}"
  rds_blocker           = "${module.first.rds_cluster_id}"

  wavefront_token       = "${var.wavefront_token}"
  wavefront_url         = "${var.wavefront_url}"
}

output "kubeconfig1" {
  value = "${module.first.kubeconfig}"
  sensitive = true
}

output "kubeconfig2" {
  value = "${module.second.kubeconfig}"
  sensitive = true
}