resource "aws_instance" "ec2_ssh" {
  ami                         = data.aws_ami.debian.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_ssm_parameter.public_subnet_1a.value
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_ssh.id]
  key_name                    = aws_key_pair.ec2_ssh.key_name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = {
    Name        = format("%s-ssh", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
