resource "aws_default_security_group" "myapp-sg" { 
  vpc_id      = var.vpc_id

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
    values = [var.image_name]
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


resource "aws_key_pair" "myapp_key" {
  key_name   = "${var.env_prefix}_key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "myapp-ec2" {
  ami           = data.aws_ami.linux_ami.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true 
  key_name = aws_key_pair.myapp_key.key_name

  user_data = file("entrypoint.sh")

  
  tags = {
    Name = "terraform_ec2"
  }
}