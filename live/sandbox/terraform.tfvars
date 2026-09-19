region                       = "us-east-1"
environment                  = "sandbox"
project_name_session_manager = "sessionmanager"
instance_type                = "t4g.small"


ssh_allowed_cidr = "203.0.113.10/32" # Exemplo: substitua pelo seu IP público com /32.

ssm_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
