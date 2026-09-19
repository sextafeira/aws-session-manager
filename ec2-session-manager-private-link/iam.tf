resource "aws_iam_role" "session_manager" {
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

resource "aws_iam_role_policy_attachment" "session_manager" {
  role       = aws_iam_role.session_manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "session_manager" {
  name = format("%s-private-link", var.project_name_session_manager)
  role = aws_iam_role.session_manager.name

  tags = {
    Name        = format("%s-session-manager-private-link", var.project_name_session_manager)
    Environment = var.environment
    Terraform   = "True"
  }
}
