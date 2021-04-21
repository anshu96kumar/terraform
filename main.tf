provider "aws"{
    region = "ap-south-1"
    access_key = "AKIAWIDGFHWB4ZM6XP6A"
    secret_key = "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"
}


resource "aws_vpc" "myapp_vpc"{
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
} 

module "myapp-subnet"{
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp_vpc.id
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

module "myapp-webserver"{
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp_vpc.id
  myip = var.myip
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_path = var.public_key_path
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet-1.id
  avail_zone = var.avail_zone
}    

