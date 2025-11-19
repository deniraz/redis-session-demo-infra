##############################################
# AMI Selection Logic
# - Dynamically selects the AMI based on os_type variable
# - Supports Ubuntu 22.04 and Amazon Linux 2023
##############################################

# Ubuntu AMI (latest)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]                # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Amazon Linux 2023 AMI (latest)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Local variables to select AMI and user-data file
locals {
  selected_ami = (
    var.os_type == "ubuntu"
    ? data.aws_ami.ubuntu.id
    : data.aws_ami.amazon_linux_2023.id
  )

  user_data_file = (
    var.os_type == "ubuntu"
    ? "${path.module}/user-data-ubuntu.sh"
    : "${path.module}/user-data-amazon-linux.sh"
  )
}

##############################################
# IAM Role + Policy + Instance Profile
# - EC2 role for accessing S3 (download JAR)
# - Instance Profile required to attach role to EC2
##############################################

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role"

  # EC2 can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Inline Policy: grant read access to specific S3 bucket
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.project}-s3-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.bucket_name}"
      }
    ]
  })
}

# Instance Profile (binds IAM role to EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

##############################################
# EC2 Instances (Multi-AZ)
# - Launches 2 instances, one in each public subnet
# - Runs application JAR via user-data
# - Injects DB + Redis environment variables
##############################################
resource "aws_instance" "app" {
  count = 2                                        # Multi-AZ deployment

  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = element([aws_subnet.public_a.id, aws_subnet.public_b.id], count.index)
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # Enforce IMDSv2 for security
  metadata_options {
    http_tokens = "required"
  }

  # Render and pass user-data template with variables
  user_data = templatefile(local.user_data_file, {
    region        = var.region
    bucket        = var.bucket_name
    bucket_region = var.bucket_region
    db_host       = aws_db_instance.pg.address
    db_name       = var.db_name
    db_user       = var.db_username
    db_pass       = var.db_password
    redis_host    = aws_elasticache_cluster.redis.cache_nodes[0].address
  })

  tags = {
    Name = "${var.project}-app-${count.index + 1}"
  }

  # Ensure RDS, Redis, and instance profile exist before EC2 creation
  depends_on = [
    aws_iam_instance_profile.ec2_profile,
    aws_db_instance.pg,
    aws_elasticache_cluster.redis
  ]
}

##############################################
# Outputs
##############################################

output "app_public_ips" {
  value = aws_instance.app[*].public_ip
}

output "app_private_ips" {
  value = aws_instance.app[*].private_ip
}
