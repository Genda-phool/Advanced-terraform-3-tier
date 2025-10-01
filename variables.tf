variable "aws_region" { default = "us-east-1" }
variable "my_home_ip" { description = "home public IP in CIDR (e.g. 1.2.3.4/32)" }
variable "db_password" { description = "RDS master password" }
variable "app_name" { default = "demo-node-app" }
variable "app_port" { default = 3000 }
