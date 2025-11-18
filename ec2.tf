##############################################
# EC2 Instance for Java Redis Session Demo
##############################################

# Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

##############################################
# IAM Role + Inline S3 Policy (GetObject + ListBucket)
##############################################

resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.project}-s3-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "arn:aws:s3:::sdenira-redis-alb-demo/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::sdenira-redis-alb-demo"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

##############################################
# EC2 Instances (2 AZ)
##############################################

resource "aws_instance" "app" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = element([aws_subnet.public_a.id, aws_subnet.public_b.id], count.index)
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # Required for cloud-init with IMDSv2
  metadata_options {
    http_tokens = "required"
  }

  ##############################################
  # FIX: Use RAW user_data (NO BASE64 ENCODING)
  ##############################################
  user_data = templatefile("${path.module}/user-data.sh", {
    region     = var.region
    bucket     = var.bucket_name
    bucket_region = var.bucket_region
    db_host    = aws_db_instance.pg.address
    db_name    = var.db_name
    db_user    = var.db_username
    db_pass    = var.db_password
    redis_host = aws_elasticache_cluster.redis.cache_nodes[0].address
  })

  tags = {
    Name = "${var.project}-app-${count.index + 1}"
  }

  depends_on = [
    aws_db_instance.pg,
    aws_elasticache_cluster.redis,
    aws_iam_instance_profile.ec2_profile
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
