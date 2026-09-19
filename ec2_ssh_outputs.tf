output "ec2_ssh_instance_id" {
  value = aws_instance.ec2_ssh.id
}

output "ec2_ssh_private_ip" {
  value = aws_instance.ec2_ssh.private_ip
}

output "ec2_ssh_public_ip" {
  value = aws_instance.ec2_ssh.public_ip
}

output "ec2_ssh_private_key_path" {
  value = local_sensitive_file.ec2_ssh.filename
}

output "ec2_ssh_command" {
  value = format("ssh -i '%s' admin@%s", local_sensitive_file.ec2_ssh.filename, aws_instance.ec2_ssh.public_ip)
}
