resource "aws_security_group" "ec2" {
  name   = format("%s-session-manager-private-link", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_security_group" "endpoints" {
  name   = format("%s-private-link-endpoints", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-private-link-endpoints", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
