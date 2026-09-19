resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ssh" {
  filename        = abspath("${path.module}/ec2-ssh.pem")
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ssh" {
  key_name   = format("%s-ssh", var.project_name_session_manager)
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name        = format("%s-ssh-key", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
