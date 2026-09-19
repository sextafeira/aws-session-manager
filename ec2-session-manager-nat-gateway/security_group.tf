resource "aws_security_group" "ec2" {
  name   = format("%s-session-manager-nat-gateway", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-session-manager-nat-gateway", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
