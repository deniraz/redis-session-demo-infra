##############################################
# PostgreSQL RDS Instance (Using Variables)
# - Creates a small PostgreSQL instance for demo use
# - Uses a subnet group (public subnets here for simplicity)
##############################################

##############################################
# Subnet Group
# - Defines which subnets the RDS instance can use
# - Using public subnets only for demo (not recommended for production)
##############################################
resource "aws_db_subnet_group" "pg_subnet" {
  name       = "${var.project}-pg-subnet"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project}-pg-subnet"
  }
}

##############################################
# RDS PostgreSQL Instance
# - db.t3.micro (smallest general purpose)
# - Not publicly accessible (private IP only)
# - Credentials and DB name supplied via variables
# - skip_final_snapshot=true for faster destroy (demo mode)
##############################################
resource "aws_db_instance" "pg" {
  identifier             = "${var.project}-pg"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20                      # 20GB storage

  db_subnet_group_name   = aws_db_subnet_group.pg_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # From terraform.tfvars
  username            = var.db_username
  password            = var.db_password
  db_name             = var.db_name

  publicly_accessible = false                     # Private DB
  skip_final_snapshot = true                      # No snapshot on destroy (demo)

  tags = {
    Name = "${var.project}-pg"
  }
}

##############################################
# Outputs
# - Useful connection details for the application
##############################################
output "rds_endpoint" {
  value = aws_db_instance.pg.address
}

output "rds_db_name" {
  value = aws_db_instance.pg.db_name
}

output "rds_username" {
  value = aws_db_instance.pg.username
}
