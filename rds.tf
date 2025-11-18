##############################################
# PostgreSQL RDS Instance (Using Variables)
##############################################

# Subnet Group
resource "aws_db_subnet_group" "pg_subnet" {
  name       = "${var.project}-pg-subnet"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project}-pg-subnet"
  }
}

##############################################
# RDS PostgreSQL Instance
##############################################
resource "aws_db_instance" "pg" {
  identifier             = "${var.project}-pg"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  db_subnet_group_name   = aws_db_subnet_group.pg_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username            = var.db_username
  password            = var.db_password
  db_name             = var.db_name
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project}-pg"
  }
}

##############################################
# Output Values
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
