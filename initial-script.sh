#!/bin/bash

# Update & Install Docker
sudo yum update -y && sudo yum install -y docker

# Enable docker at the start
sudo systemctl enable docker

# Start Docker
sudo systemctl start docker

# Add ec2-user to docker group

sudo usermod -aG docker ec2-user

# Run nginx as docker image

docker run -p 8080:80 nginx