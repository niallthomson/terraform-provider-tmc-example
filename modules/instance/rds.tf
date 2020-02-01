resource "null_resource" "rds_blocker" {
  provisioner "local-exec" {
    command = "echo ${var.rds_blocker}"
  }
}

resource "aws_rds_cluster" "cluster" {
  depends_on = ["null_resource.rds_blocker"]

  cluster_identifier        = "bootcamp-${var.id}-${local.region_short}"
  availability_zones        = "${var.azs[var.region]}"
  master_username           = "${var.rds_blocker == "" ? "masteruser" : ""}"
  master_password           = "${var.rds_blocker == "" ? "foobar12345" : ""}"
  backup_retention_period   = 5
  preferred_backup_window   = "07:00-09:00"
  engine_mode               = "global"
  skip_final_snapshot       = true
  global_cluster_identifier = "${var.rds_global_cluster_id}"
}

resource "aws_rds_cluster_instance" "instance" {
  identifier         = "bootcamp-${var.id}-${local.region_short}-${count.index}"
  cluster_identifier = "${aws_rds_cluster.cluster.id}"
  instance_class     = "db.r4.large"
}