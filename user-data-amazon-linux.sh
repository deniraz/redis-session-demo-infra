#!/bin/bash
set -e

############################################
# UPDATE & INSTALL JAVA 21 + AWS CLI
############################################
dnf update -y
dnf install -y java-21-amazon-corretto awscli

# Set AWS CLI default region
aws configure set region ${region}

############################################
# Download JAR
############################################
cd /home/ec2-user

echo "Downloading app JAR..."
aws s3 cp s3://${bucket}/redis-session-login.jar /home/ec2-user/app.jar --region ${bucket_region}
chown ec2-user:ec2-user /home/ec2-user/app.jar

############################################
# GLOBAL ENV VARS
############################################
cat <<EOT > /etc/profile.d/app_env.sh
export DB_HOST=${db_host}
export DB_NAME=${db_name}
export DB_USER=${db_user}
export DB_PASS=${db_pass}
export REDIS_HOST=${redis_host}
EOT

chmod +x /etc/profile.d/app_env.sh

############################################
# EXPORT ENV FOR USER-DATA CONTEXT
############################################
export DB_HOST=${db_host}
export DB_NAME=${db_name}
export DB_USER=${db_user}
export DB_PASS=${db_pass}
export REDIS_HOST=${redis_host}

echo "==== ENV just before starting app ====" > /home/ec2-user/env.log
env >> /home/ec2-user/env.log
chown ec2-user:ec2-user /home/ec2-user/env.log

############################################
# START SPRING BOOT
############################################
echo "Starting Spring Boot app..." >> /home/ec2-user/app.log

nohup java -jar /home/ec2-user/app.jar >> /home/ec2-user/app.log 2>&1 &
chown ec2-user:ec2-user /home/ec2-user/app.log
