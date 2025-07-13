locals {
  tags = {
    environment = "dev"
    project     = "2048-game"
  }
  region            = "eu-west-2"
  availability_zone = ["eu-west-2a", "eu-west-2b", "eu-west-2b"]
  cluster_name = "project_cluster"
}