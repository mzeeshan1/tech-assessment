locals {
  name   = "tech-assessment-cluster"
  region = "eu-central-1"
  azs    = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    cluster = "tech-assessment"
  }

}


data "aws_availability_zones" "available" {
  # Do not include local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

