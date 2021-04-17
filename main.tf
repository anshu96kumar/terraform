provider "aws"{
    region = "ap-south-1"

}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix{}
variable myip{}
variable instance_type{}
variable public_key_path{}

resource "aws_vpc" "myapp_vpc"{
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp_subnet_1"{
    vpc_id = aws_vpc.myapp_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myapp_vpc.id
    tags =  {
        Name: "${var.env_prefix}-igw"
    } 
}

resource "aws_default_route_table" "drtb" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "drtb"
  }
}

resource "aws_default_security_group" "myapp-sg" { 
  vpc_id      = aws_vpc.myapp_vpc.id

  ingress {
    description      = "port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.myip]
  }
   ingress {
    description      = "port 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "linux_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# output "aoutput_ami" {
#   value       =  data.aws_ami.linux_ami.id
# }

resource "aws_key_pair" "myapp_key" {
  key_name   = "${var.env_prefix}_key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "myapp-ec2" {
  ami           = data.aws_ami.linux_ami.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true 
  key_name = aws_key_pair.myapp_key.key_name

    user_data = file("entrypoint.sh")

  tags = {
    Name = "HelloWorld"
  }
}

output "server_ip" {
  value       = aws_instance.myapp-ec2.public_ip
}


