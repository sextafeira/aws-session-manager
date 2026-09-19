data "aws_ssm_parameter" "vpc" {
  name = format("/%s/aws-vpc/vpc_id", var.project_name_session_manager)
}

data "aws_ssm_parameter" "private_subnet_1a" {
  name = format("/%s/aws-vpc/private_subnet_1a_id", var.project_name_session_manager)
}

data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}
