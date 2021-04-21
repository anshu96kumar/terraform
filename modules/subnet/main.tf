resource "aws_subnet" "myapp_subnet_1"{
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = var.vpc_id
    tags =  {
        Name: "${var.env_prefix}-igw"
    } 
}

resource "aws_default_route_table" "drtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "drtb"
  }
}