provider "tmc" {
  api_key = "${var.key}"
}

resource "random_id" "id" {
  byte_length = 4
}

resource "tmc_cluster_group" "group" {
  name        = "bootcamp-group-${random_id.id.hex}"
  description = "Bootcamp group ${random_id.id.hex}"
}

resource "tmc_cluster" "tester" {
  name          = "bootcamp-${random_id.id.hex}"
  description   = "Bootcamp cluster ${random_id.id.hex}"
  group         = "${tmc_cluster_group.group.name}"
  account_name  = "PA-nthomson"

  aws_config {
    control_plane_vm_flavor = "m5.large"
    ssh_key_name            = "default"
    vpc_cidr_block          = "10.0.0.0/16"
    region                  = "us-west-2"
    az_list                 = ["us-west-2a","us-west-2b","us-west-2c"]
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
      zone          = "us-west-2a"
    }
  }
}

data "tmc_kubeconfig" "kubeconfig" {
  name = "${tmc_cluster.tester.provisioned_name}"
}