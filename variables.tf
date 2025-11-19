##############################################
# AWS Region
# - Controls where all resources are deployed
##############################################
variable "region" {
  type        = string
  default     = "ap-southeast-3"
}

##############################################
# S3 Bucket Region
# - Region where the JAR file bucket is located
# - Used by user-data to download application JAR
##############################################
variable "bucket_region" {
  type        = string
  description = "Region of S3 bucket used for downloading JAR"
}

##############################################
# S3 Bucket Name
# - Bucket that stores the application JAR file
##############################################
variable "bucket_name" {
  type        = string
  description = "S3 bucket name for downloading JAR"
}

##############################################
# Project Name Prefix
# - Used for tagging and naming AWS resources
##############################################
variable "project" {
  type    = string
  default = "java-redis-login-demo"
}

##############################################
# EC2 Key Pair Name
# - Required for SSH access to EC2 instances
##############################################
variable "key_name" {
  type        = string
  description = "Existing EC2 keypair name"
}

##############################################
# EC2 Instance Type
# - Default: t3.micro (demo-sized)
##############################################
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

##############################################
# Operating System Selection
# - Accepts: "ubuntu" or "amazon-linux"
# - Determines AMI and user-data script
##############################################
variable "os_type" {
  type        = string
  description = "ubuntu | amazon-linux"
  default     = "ubuntu"

  # Optional validation block
  # validation {
  #   condition     = var.os_type == "ubuntu" || var.os_type == "amazon-linux"
  #   error_message = "os_type must be either 'ubuntu' or 'amazon-linux'."
  # }
}

##############################################
# Allowed IP for SSH
# - Used in EC2 security group to control SSH access
##############################################
variable "allowed_ip" {
  type        = string
  default     = "0.0.0.0/0"
}

##############################################
# RDS Variables
# - Credentials and DB name for PostgreSQL instance
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
