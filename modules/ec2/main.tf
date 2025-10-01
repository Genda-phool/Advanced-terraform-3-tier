resource "random_id" "bucket" { byte_length = 4 }

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_name}-artifacts-${random_id.bucket.hex}"
  acl = "private"
  force_destroy = true
}

data "aws_iam_policy_document" "assume_role" {
  statement { actions = ["sts:AssumeRole"] principals { type = "Service" identifiers = ["ec2.amazonaws.com"] } }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-${random_id.iam.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "random_id" "iam" { byte_length = 4 }

data "aws_iam_policy_document" "ec2_policy" {
  statement { actions = ["s3:GetObject", "s3:ListBucket"] resources = [aws_s3_bucket.app_bucket.arn, "${aws_s3_bucket.app_bucket.arn}/*"] }
  statement { actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"], resources = ["arn:aws:ssm:${var.aws_region}:*:/parameter/${var.app_name}/*"] }
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2-s3-ssm-policy"
  role = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${random_id.profile.hex}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"
  vpc_id = var.vpc_id
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port = var.app_port; to_port = var.app_port; protocol = "tcp"; cidr_blocks = ["10.0.0.0/8"] }
  ingress { from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["10.0.0.0/8"] }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter { name = "name"; values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name = var.key_name
  user_data = file("${path.module}/../../cloud-init/web-user-data.yaml.tpl")
  tags = { Name = "web-private" }
  depends_on = [aws_iam_role_policy.ec2_policy]
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = var.alb_target_group_arn
  target_id = aws_instance.web.id
  port = var.app_port
}

output "bucket_name" { value = aws_s3_bucket.app_bucket.bucket }
output "instance_id" { value = aws_instance.web.id }
output "instance_private_ip" { value = aws_instance.web.private_ip }
output "instance_profile_name" { value = aws_iam_instance_profile.ec2_profile.name }
