terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    random = { source = "hashicorp/random" }
    archive = { source = "hashicorp/archive" }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  app_port = var.app_port
}

module "bastion" {
  source = "./modules/bastion"
  public_subnet_id = module.vpc.public_subnet_id
  public_subnet_vpc_id = module.vpc.vpc_id
  my_home_ip = var.my_home_ip
}

module "rds" {
  source = "./modules/rds"
  private_subnet_id = module.vpc.private_subnet_id
  db_password = var.db_password
  vpc_id = module.vpc.vpc_id
}

module "ssm" {
  source = "./modules/ssm"
  app_name = var.app_name
  db_host = module.rds.db_address
  db_user = module.rds.db_username
  db_pass = var.db_password
}

module "ec2" {
  source = "./modules/ec2"
  private_subnet_id = module.vpc.private_subnet_id
  vpc_id = module.vpc.vpc_id
  app_name = var.app_name
  app_port = var.app_port
  key_name = module.bastion.key_name
  alb_target_group_arn = module.alb.tg_arn
  aws_region = var.aws_region
}

module "ec2_app_bucket" {
  source = "./modules/ec2"
  create_only_bucket = true
  app_name = var.app_name
}

output "alb_dns" { value = module.alb.alb_dns }
output "bastion_ip" { value = module.bastion.bastion_ip }
output "db_endpoint" { value = module.rds.db_address }
