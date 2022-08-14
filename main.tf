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


# To create a subnet in custom VPC in one of the availability-zone
resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}


# To create a custom route table for the subnet
resource "aws_route_table" "my-subnet-rtb" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-subnet-rtb"
  }
}


# To create a Internet gateway

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }

}


# To associate route table to Subnet

resource "aws_route_table_association" "associate-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-subnet-rtb.id
}



### EC2 SERVER and it's associated resources

resource "aws_instance" "my-server" {
  ami = data.aws_ami.image_name.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.my-subnet.id

  key_name = aws_key_pair.my-server-key.key_name

  # vpc_security_group_ids = [aws_default_security_group.default-sg.id]

  availability_zone = var.avail_zone

  associate_public_ip_address = true

  user_data = file("initial-script.sh")

  tags = {
    "Name" = "${var.env_prefix}-server"
  }

}


### Query through data-source to get latest Amazon linux AMI image id

data "aws_ami" "image_name" {
  owners = ["amazon"]
  most_recent = true

    filter {
      name = "name"
      values = [var.image_name]
    }

    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


## Create a Key pair to SSH into EC2-server

resource "aws_key_pair" "my-server-key" {
  key_name = "my-server-key"
  public_key = var.public_key_data
}



### Create a security group for EC2 server to open port 80 & 8080

# resource "aws_security_group" "my-sg" {
#   # name = "my-sg"
#   vpc_id = aws_vpc.my-vpc.id

#   ingress = [ {
#     description = "my-sg-80"
#     cidr_blocks = ["${var.my_ip}"]
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     ipv6_cidr_blocks = [aws_vpc.my-vpc.ipv6_cidr_block]
#     prefix_list_ids  = null
#     security_groups  = null
#     self = false
#   } ,
#   {
#     description = "my-sg-8080"
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     ipv6_cidr_blocks = [aws_vpc.my-vpc.ipv6_cidr_block]
#     prefix_list_ids  = null
#     security_groups  = null
#     self = false
#   }
#   ]

#   egress = [ {
#     description = "Outbound"
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     prefix_list_ids = null
#     ipv6_cidr_blocks = [aws_vpc.my-vpc.ipv6_cidr_block]
#     security_groups  = null
#     self = false
#   } ]


#   tags = {
#     "Name" = "${var.env_prefix}-sg"
#   }
# }




