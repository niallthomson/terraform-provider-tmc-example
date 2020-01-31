variable "zones" {
  type = "list"
  default = ["us-east-2", "us-west-2", "eu-west-1"]
}

variable "azs" {
  type = "map"

  default = {
    us-east-2 = ["us-east-2a","us-east-2b","us-east-2c"]
    us-west-2 = ["us-west-2a","us-west-2b","us-west-2c"]
    eu-west-1 = ["eu-west-1a","eu-west-1b","eu-west-1c"]
  }
}