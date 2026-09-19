output "ec2_session_manager_nat_gateway_instance_id" {
  value = aws_instance.ec2_session_manager_nat_gateway.id
}

output "ec2_session_manager_nat_gateway_private_ip" {
  value = aws_instance.ec2_session_manager_nat_gateway.private_ip
}

output "ec2_session_manager_nat_gateway_command" {
  value = format("aws ssm start-session --region %s --target %s", var.region, aws_instance.ec2_session_manager_nat_gateway.id)
}
