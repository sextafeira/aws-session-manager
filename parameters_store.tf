resource "aws_ssm_parameter" "vpc" {
  name  = format("/%s/aws-vpc/vpc_id", var.project_name_session_manager)
  type  = "String"
  value = aws_vpc.main.id

  tags = {
    Name        = format("%s-vpc-id", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_ssm_parameter" "public_subnet_1a" {
  name  = format("/%s/aws-vpc/public_subnet_1a_id", var.project_name_session_manager)
  type  = "String"
  value = aws_subnet.public_subnet_1a.id

  tags = {
    Name        = format("%s-public-subnet-1a-id", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_ssm_parameter" "private_subnet_1a" {
  name  = format("/%s/aws-vpc/private_subnet_1a_id", var.project_name_session_manager)
  type  = "String"
  value = aws_subnet.private_subnet_1a.id

  tags = {
    Name        = format("%s-private-subnet-1a-id", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
