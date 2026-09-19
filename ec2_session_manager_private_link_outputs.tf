output "ec2_session_manager_private_link_instance_id" {
  value = aws_instance.ec2_session_manager_private_link.id
}

output "ec2_session_manager_private_link_private_ip" {
  value = aws_instance.ec2_session_manager_private_link.private_ip
}

output "ec2_session_manager_private_link_command" {
  value = format("aws ssm start-session --region %s --target %s", var.region, aws_instance.ec2_session_manager_private_link.id)
}
