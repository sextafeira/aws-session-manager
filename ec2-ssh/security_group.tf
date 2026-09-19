resource "aws_security_group" "ec2" {
  name   = format("%s-ssh", var.project_name_session_manager)
  vpc_id = data.aws_ssm_parameter.vpc.value

  tags = {
    Name        = format("%s-ssh", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
