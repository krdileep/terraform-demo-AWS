
# To create a subnet in custom VPC in one of the availability-zone
resource "aws_subnet" "my-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}


# To create a custom route table for the subnet
resource "aws_route_table" "my-subnet-rtb" {
  vpc_id = var.vpc_id

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
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }

}


# To associate route table to Subnet

resource "aws_route_table_association" "associate-rtb-subnet" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-subnet-rtb.id
}
