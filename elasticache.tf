##############################################
# ElastiCache Subnet Group
# - Defines which subnets Redis is allowed to use
# - Using public subnets (demo environment)
##############################################
resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "${var.project}-redis-subnet"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project}-redis-subnet"
  }
}

##############################################
# Redis ElastiCache Cluster
# - Single-node Redis cluster (cache.t3.micro)
# - Port 6379
# - Uses Redis 7 default parameter group
# - Uses dedicated Redis SG (ingress only from EC2 SG)
##############################################
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"             # Small instance for demo
  num_cache_nodes      = 1                           # Single-node Redis (not clustered)
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  parameter_group_name = "default.redis7"            # Redis 7 parameter group

  tags = {
    Name = "${var.project}-redis"
  }
}

##############################################
# Outputs
# - Redis endpoint used by application
# - Redis connection port
##############################################
output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.redis.port
}
