##############################################
# EC2 Security Group
# - Allows SSH only from allowed_ip variable
# - Allows HTTP (8080) from anywhere (demo setup)
# - Outbound traffic fully allowed
##############################################
resource "aws_security_group" "ec2_sg" {
  name   = "${var.project}-ec2-sg"
  vpc_id = aws_vpc.main.id

  # SSH access (restricted)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]               # Typically set to your public IP
  }

  # Application port (open for demo)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                  # Public access (demo only)
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
# ALB Security Group
# - Allows inbound HTTP (80) from anywhere
# - Outbound fully open
##############################################
resource "aws_security_group" "alb_sg" {
  name   = "${var.project}-alb-sg}"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                  # Public HTTP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
# Redis Security Group
# - Allows Redis port (6379) only from EC2 security group
# - EC2 instances are the only allowed clients
##############################################
resource "aws_security_group" "redis_sg" {
  name   = "${var.project}-redis-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]   # Only EC2 app servers
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
# RDS Security Group
# - Allows PostgreSQL only from EC2 instances
# - Ensures DB is not exposed publicly
##############################################
resource "aws_security_group" "rds_sg" {
  name   = "${var.project}-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]   # Only EC2 app servers
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
# Output IDs for reference or cross-module use
##############################################
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}
