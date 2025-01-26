data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name = "default-for-az"
    values = ["true"]
  }
}

data "aws_s3_bucket" "valheim_s3_bucket" {
  bucket = var.server_data_bucket_name
}

data "aws_ssm_parameter" "server_password" {
  name = var.server_password_parameter_name
}

data "aws_ssm_parameter" "world_name" {
  name = var.world_parameter_name
}
