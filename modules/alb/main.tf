resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  vpc_id = var.vpc_id
  ingress { from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=443; to_port=443; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_lb" "alb" {
  name = "app-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = [var.public_subnet_id]
}

resource "aws_lb_target_group" "tg" {
  name = "app-tg"
  port = var.app_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check { path = "/health"; healthy_threshold = 2; unhealthy_threshold = 2; interval = 30 }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward"; target_group_arn = aws_lb_target_group.tg.arn }
}

output "alb_dns" { value = aws_lb.alb.dns_name }
output "tg_arn" { value = aws_lb_target_group.tg.arn }
