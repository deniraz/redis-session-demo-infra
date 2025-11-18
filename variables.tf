variable "region" {
  type        = string
  default     = "ap-southeast-3"
}

variable "bucket_region" {
  type = string
  description = "Region of S3 bucket used for downloading JAR"
}

variable "bucket_name" {
  type = string
  description = "S3 bucket name for doenloading JAR"
}

variable "project" {
  type    = string
  default = "java-redis-login-demo"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 keypair name"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_ip" {
  type        = string
  default     = "0.0.0.0/0"
}

##############################################
# RDS Variables
##############################################
variable "db_username" {
  type        = string
  description = "Database username for RDS"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password for RDS"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

