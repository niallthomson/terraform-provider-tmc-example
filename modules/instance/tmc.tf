resource "tmc_cluster" "tester" {
  name          = "bootcamp-${var.id}-${local.region_short}"
  description   = "Bootcamp cluster ${var.id} in ${var.region}"
  group         = "${var.tmc_cluster_group}"
  account_name  = "PA-nthomson"

  aws_config {
    control_plane_vm_flavor = "m5.large"
    ssh_key_name            = "default"
    vpc_cidr_block          = "10.0.0.0/16"
    region                  = "${var.region}"
    az_list                 = "${var.azs[var.region]}"
  }

  network_config {
    pod_cidr     = "192.168.0.0/16"
    service_cidr = "10.96.0.0/12"
  }

  node_pool {
    name = "pool1"
    worker_node_count = 2

    aws_config {
      instance_type = "m5.large"
      zone          = "${element(var.azs[var.region], 0)}"
    }
  }
}

data "tmc_kubeconfig" "kubeconfig" {
  name = "${tmc_cluster.tester.provisioned_name}"
}