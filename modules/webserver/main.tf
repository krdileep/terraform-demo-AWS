### EC2 SERVER and it's associated resources

resource "aws_instance" "my-server" {
  ami           = data.aws_ami.image_name.id
  instance_type = var.instance_type

  # subnet_id = aws_subnet.my-subnet.id
  subnet_id = var.subnet_id 

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
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


## Create a Key pair to SSH into EC2-server

resource "aws_key_pair" "my-server-key" {
  key_name   = "my-server-key"
  public_key = var.public_key_data
}