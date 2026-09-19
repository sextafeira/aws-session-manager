resource "aws_instance" "main" {
  ami                         = data.aws_ssm_parameter.amazon_linux.value
  instance_type               = var.instance_type
  subnet_id                   = data.aws_ssm_parameter.private_subnet_1a.value
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.session_manager.name

  # A AMI padrão do Amazon Linux 2023 já inclui o SSM Agent.
  user_data = <<-EOF
    #!/bin/bash
    systemctl enable --now amazon-ssm-agent
  EOF

  depends_on = [
    aws_iam_role_policy_attachment.session_manager,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages,
    aws_vpc_security_group_egress_rule.https,
    aws_vpc_security_group_ingress_rule.endpoints_https,
  ]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
