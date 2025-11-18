##############################################
# Application Load Balancer
##############################################
resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project}-alb"
  }
}

##############################################
# Target Group
##############################################
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/actuator/health"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  # stickiness {
  #   type            = "lb_cookie"
  #   cookie_duration = 300
  #   enabled         = true
  # }

  tags = {
    Name = "${var.project}-tg"
  }
}


##############################################
# Listener
##############################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

##############################################
# Attach EC2 Targets
##############################################
resource "aws_lb_target_group_attachment" "attach" {
  count            = length(aws_instance.app)
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app[count.index].id
  port             = 8080
}

##############################################
# Output
##############################################
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
