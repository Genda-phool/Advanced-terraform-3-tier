resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 3306; to_port = 3306; protocol = "tcp"; cidr_blocks = ["10.0.0.0/8"] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_db_subnet_group" "rds_subnets" {
  name = "rds-subnet-group"
  subnet_ids = [var.private_subnet_id]
}

resource "aws_db_instance" "mysql" {
  identifier = "tf-demo-db-${random_id.db.hex}"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  name = "demodb"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  publicly_accessible = false
}

resource "random_id" "db" { byte_length = 4 }

output "db_address" { value = aws_db_instance.mysql.address }
output "db_username" { value = var.db_username }
