resource "aws_security_group" "ec2_session_manager_private_link" {
  name   = format("%s-session-manager-private-link", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_security_group" "ec2_session_manager_private_link_endpoints" {
  name   = format("%s-private-link-endpoints", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-private-link-endpoints", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_session_manager_private_link_https" {
  security_group_id            = aws_security_group.ec2_session_manager_private_link.id
  referenced_security_group_id = aws_security_group.ec2_session_manager_private_link_endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_session_manager_private_link_endpoints_https" {
  security_group_id            = aws_security_group.ec2_session_manager_private_link_endpoints.id
  referenced_security_group_id = aws_security_group.ec2_session_manager_private_link.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_session_manager_nat_gateway_endpoints_https" {
  security_group_id            = aws_security_group.ec2_session_manager_private_link_endpoints.id
  referenced_security_group_id = aws_security_group.ec2_session_manager_nat_gateway.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
