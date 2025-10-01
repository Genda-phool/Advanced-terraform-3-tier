resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  vpc_id = var.public_subnet_vpc_id
  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=[var.my_home_ip] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_key_pair" "bastion_key" {
  key_name = "bastion-key-${random_id.key.hex}"
  public_key = file(var.ssh_pub_key_path)
}

resource "random_id" "key" { byte_length = 4 }

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.bastion_key.key_name
  tags = { Name = "bastion" }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter { name = "name"; values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] }
}

output "bastion_ip" { value = aws_instance.bastion.public_ip }
output "key_name" { value = aws_key_pair.bastion_key.key_name }
