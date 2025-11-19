##############################################
# CloudWatch Dashboard for Redis Metrics
# - Displays key Redis performance metrics
# - Includes: connections, CPU, memory, hits/misses
##############################################
resource "aws_cloudwatch_dashboard" "redis_dashboard" {
  dashboard_name = "${var.project}-redis-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      ##############################################
      # 1. Current Connections
      # - Shows the number of active Redis client connections
      # - Useful for tracking load and connection spikes
      ##############################################
      {
        "type"  : "metric",
        "x"     : 0,
        "y"     : 0,
        "width" : 12,
        "height": 6,
        "properties": {
          "title" : "Redis - Current Connections",
          "region": var.region,
          "view"  : "timeSeries",
          "stacked": false,
          "period": 60,
          "metrics": [
            [ "AWS/ElastiCache", "CurrConnections", "CacheClusterId", aws_elasticache_cluster.redis.id, { "stat": "Average" } ]
          ]
        }
      },

      ##############################################
      # 2. CPU Utilization
      # - Displays Redis node CPU usage
      # - Helps monitor performance bottlenecks
      ##############################################
      {
        "type"  : "metric",
        "x"     : 12,
        "y"     : 0,
        "width" : 12,
        "height": 6,
        "properties": {
          "title" : "Redis - CPU Utilization",
          "region": var.region,
          "view"  : "timeSeries",
          "stacked": false,
          "period": 60,
          "metrics": [
            [ "AWS/ElastiCache", "CPUUtilization", "CacheClusterId", aws_elasticache_cluster.redis.id, { "stat": "Average" } ]
          ]
        }
      },

      ##############################################
      # 3. Freeable Memory
      # - Shows available memory in bytes
      # - Important for diagnosing memory pressure
      ##############################################
      {
        "type"  : "metric",
        "x"     : 0,
        "y"     : 6,
        "width" : 12,
        "height": 6,
        "properties": {
          "title" : "Redis - Freeable Memory (Bytes)",
          "region": var.region,
          "view"  : "timeSeries",
          "stacked": false,
          "period": 60,
          "metrics": [
            [ "AWS/ElastiCache", "FreeableMemory", "CacheClusterId", aws_elasticache_cluster.redis.id, { "stat": "Average" } ]
          ]
        }
      },

      ##############################################
      # 4. CacheHits vs CacheMisses
      # - Tracks how often Redis returns cached data vs misses
      # - Good indicator of cache effectiveness
      ##############################################
      {
        "type"  : "metric",
        "x"     : 12,
        "y"     : 6,
        "width" : 12,
        "height": 6,
        "properties": {
          "title" : "Redis - Cache Hits vs Misses",
          "region": var.region,
          "view"  : "timeSeries",
          "stacked": false,
          "period": 60,
          "metrics": [
            [ "AWS/ElastiCache", "CacheHits",   "CacheClusterId", aws_elasticache_cluster.redis.id, { "stat": "Sum" } ],
            [ "AWS/ElastiCache", "CacheMisses", "CacheClusterId", aws_elasticache_cluster.redis.id, { "stat": "Sum" } ]
          ]
        }
      }

    ]
  })
}

##############################################
# Outputs
##############################################

output "redis_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.redis_dashboard.dashboard_name
}

output "redis_dashboard_url" {
  description = "Direct link to the CloudWatch dashboard in AWS Console"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.redis_dashboard.dashboard_name}"
}
