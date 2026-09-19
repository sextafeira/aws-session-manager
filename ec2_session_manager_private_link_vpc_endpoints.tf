resource "aws_vpc_endpoint" "ec2_session_manager_private_link_ssm" {
  vpc_id              = data.aws_ssm_parameter.vpc.value
  service_name        = format("com.amazonaws.%s.ssm", var.region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [data.aws_ssm_parameter.private_subnet_1a.value]
  security_group_ids  = [aws_security_group.ec2_session_manager_private_link_endpoints.id]

  tags = {
    Name        = format("%s-private-link-ssm", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_vpc_endpoint" "ec2_session_manager_private_link_ssmmessages" {
  vpc_id              = data.aws_ssm_parameter.vpc.value
  service_name        = format("com.amazonaws.%s.ssmmessages", var.region)
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [data.aws_ssm_parameter.private_subnet_1a.value]
  security_group_ids  = [aws_security_group.ec2_session_manager_private_link_endpoints.id]

  tags = {
    Name        = format("%s-private-link-ssmmessages", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
