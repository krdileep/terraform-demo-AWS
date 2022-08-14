provider "aws" {
  region = "ap-south-1"
}

## VPC and Subnet resources

# To Create a custom VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}



# Calling Subnet Module

module "my-subnet" {
  source     = "./modules/subnet"
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
}


# Calling EC2-Server module

module "webserver" {
  source          = "./modules/webserver"
  avail_zone      = var.avail_zone
  env_prefix      = var.env_prefix
  instance_type   = var.instance_type
  subnet_id       = module.my-subnet.subnet.id
  image_name      = var.image_name
  public_key_data = var.public_key_data

}








