locals {
  region_short = "${var.regions_short[var.region]}"
}

provider "aws" {
  region = "${var.region}"
}