data "aws_ssm_parameter" "vpc" {
  name = "/aws-vpc/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_1a" {
  name = "/aws-vpc/public_subnet_1a_id"
}

data "aws_ssm_parameter" "private_subnet_1a" {
  name = "/aws-vpc/private_subnet_1a_id"
}
