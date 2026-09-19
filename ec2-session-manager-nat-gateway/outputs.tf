output "instance_id" {
  value = aws_instance.main.id
}

output "private_ip" {
  value = aws_instance.main.private_ip
}

output "session_manager_command" {
  value = format("aws ssm start-session --region %s --target %s", var.region, aws_instance.main.id)
}
