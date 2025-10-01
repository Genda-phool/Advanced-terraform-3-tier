# Terraform 3-Tier Modular Demo (Node.js + MySQL)
This demo provisions a VPC, ALB, Bastion, private web EC2, RDS MySQL, SSM parameters, and uses cloud-init to deploy
a Node.js REST API that connects to the RDS database. The Terraform is split into modules for clarity.

**Contents**
- modules/: terraform modules (vpc, alb, ec2, rds, bastion, ssm)
- app-src/: Node.js REST API (Express + mysql2)
- cloud-init/: cloud-init user-data used by the web EC2 to pull app from S3, run migrations and start service
- terraform.tfvars.example: sample variables file

Run `terraform init && terraform apply` after adjusting terraform.tfvars.
