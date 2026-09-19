data "aws_ssm_parameter" "vpc" {
  name = format("/%s/aws-vpc/vpc_id", var.project_name_session_manager)
}

data "aws_ssm_parameter" "public_subnet_1a" {
  name = format("/%s/aws-vpc/public_subnet_1a_id", var.project_name_session_manager)
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-13-arm64-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
