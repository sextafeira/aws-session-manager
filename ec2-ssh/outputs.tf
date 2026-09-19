output "instance_id" {
  value = aws_instance.main.id
}

output "private_ip" {
  value = aws_instance.main.private_ip
}

output "public_ip" {
  value = aws_instance.main.public_ip
}

output "private_key_path" {
  value = local_sensitive_file.ssh.filename
}

output "ssh_command" {
  value = format("ssh -i '%s' admin@%s", local_sensitive_file.ssh.filename, aws_instance.main.public_ip)
}
