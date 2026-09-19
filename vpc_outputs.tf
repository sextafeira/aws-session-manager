output "vpc_id" {
  value = data.aws_ssm_parameter.vpc.value
}

output "public_subnet_1a_id" {
  value = data.aws_ssm_parameter.public_subnet_1a.value
}

output "private_subnet_1a_id" {
  value = data.aws_ssm_parameter.private_subnet_1a.value
}
