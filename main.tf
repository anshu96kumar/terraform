provider "aws"{
    region = "ap-south-1"

}

variable "subnet_deployment_cidr" {
  description = "description"
}




resource "aws_vpc" "deployment"{
    cidr_block = "10.0.0.0/16"
    tags={
        Name = "deployment_vpc"
    }
}

resource "aws_subnet" "deployment_subnet"{
    vpc_id = aws_vpc.deployment.id
    cidr_block = var.subnet_deployment_cidr
        tags={
        Name = "deployment_subnet"
    }
}

output "subnet_output" {
  value       = aws_subnet.deployment_subnet.id
}
