variable "tmc_key" {}

variable "acme_email" {}

variable "root_hosted_zone_id" {}

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

module "first" {
  source = "./modules/instance"

  id                  = "${random_id.id.hex}"
  tmc_cluster_group   = "${tmc_cluster_group.group.name}"
  acme_email          = "${var.acme_email}"
  root_hosted_zone_id = "${var.root_hosted_zone_id}"
  region              = "us-west-2"
}

module "second" {
  source = "./modules/instance"

  id                  = "${random_id.id.hex}"
  tmc_cluster_group   = "${tmc_cluster_group.group.name}"
  acme_email          = "${var.acme_email}"
  root_hosted_zone_id = "${var.root_hosted_zone_id}"
  region              = "eu-west-1"
}

output "kubeconfig1" {
  value = "${module.first.kubeconfig}"
}

output "kubeconfig2" {
  value = "${module.second.kubeconfig}"
}