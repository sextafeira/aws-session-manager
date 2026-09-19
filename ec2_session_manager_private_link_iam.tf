resource "aws_iam_role" "ec2_session_manager_private_link" {
  name = format("%s-private-link", var.project_name_session_manager)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_session_manager_private_link" {
  role       = aws_iam_role.ec2_session_manager_private_link.name
  policy_arn = var.ssm_policy_arn
}

resource "aws_iam_instance_profile" "ec2_session_manager_private_link" {
  name = format("%s-private-link", var.project_name_session_manager)
  role = aws_iam_role.ec2_session_manager_private_link.name

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
