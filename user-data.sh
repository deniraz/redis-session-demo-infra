#!/bin/bash
set -e

apt update -y
apt install -y openjdk-21-jdk awscli -y

# Set region untuk AWS CLI
aws configure set region ${region}

cd /home/ubuntu

echo "Downloading app JAR..."
aws s3 cp s3://${bucket}/redis-session-login.jar /home/ubuntu/app.jar --region ${bucket_region}
chown ubuntu:ubuntu /home/ubuntu/app.jar

############################################
# GLOBAL ENV VARS (system-wide)
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
# EXPORT ENV FOR THIS SCRIPT (dan anak-anaknya)
############################################
export DB_HOST=${db_host}
export DB_NAME=${db_name}
export DB_USER=${db_user}
export DB_PASS=${db_pass}
export REDIS_HOST=${redis_host}

echo "==== ENV just before starting app ====" > /home/ubuntu/env.log
env >> /home/ubuntu/env.log

############################################
# Start Spring Boot
############################################
echo "Starting Spring Boot app..." >> /home/ubuntu/app.log
nohup java -jar /home/ubuntu/app.jar >> /home/ubuntu/app.log 2>&1 &
