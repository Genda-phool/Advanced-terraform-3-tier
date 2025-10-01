variable "private_subnet_id" {}
variable "vpc_id" {}
variable "app_name" {}
variable "app_port" { default = 3000 }
variable "key_name" {}
variable "alb_target_group_arn" {}
variable "create_only_bucket" { default = false }
variable "aws_region" { default = "us-east-1" }
