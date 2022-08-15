provider "aws" {
  region = "ap-south-1"
}


# Module section for creating VPC(Worker nodes) for EKS cluster
module "my-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"


  # Name
  name = "${var.env_prefix}-vpc"


  # The CIDR block for the VPC
  cidr = var.vpc_cidr_block

  # A list of public subnets inside the VPC
  public_subnets = var.public_cidr_blocks

  # A list of private subnets inside the VPC
  private_subnets = var.private_cidr_blocks

  # A list of availability zones names or ids in the region
  # Query the list of AZ's from datasource 
  azs = data.aws_availability_zones.my-azs.names

  # Should be true if you want to provision NAT Gateways for each of your private networks  
  enable_nat_gateway = true

  # Should be true if you want to provision a single shared NAT Gateway across all of your private networks
  single_nat_gateway = true

  # Enable dns hostnames
  enable_dns_hostnames = true

  # Below Tags are required
  # To identify a cluster's subnets, the Kubernetes Cloud Controller Manager (cloud-controller-manager) 
  # and AWS Load Balancer Controller (aws-load-balancer-controller) 
  # query the cluster's subnets by using the following tag as a filter:

  # Tags for VPC
  # For public and private subnets used by load balancer resources
  # Tag all public and private subnets that your cluster uses for load balancer resources 
  # with the following key-value pair: 
  # Key: kubernetes.io/cluster/cluster-name
  # Value: shared
  tags = {
    "kubernetes.io/cluster/dev-cluster" = "shared"
  }

  # Additional tags for the public subnets
  # For public subnets used by external load balancers
  # To allow Kubernetes to use only tagged subnets for external load balancers, 
  # tag all public subnets in your VPC with the following key-value pair:
  # Key: kubernetes.io/role/elb
  # Value: 1

  public_subnet_tags = {
    "kubernetes.io/cluster/dev-cluster" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }

  # Additional tags for the private subnets
  # For private subnets used by internal load balancers
  # To allow Kubernetes to use your private subnets for internal load balancers, 
  # tag all private subnets in your VPC with the following key-value pair:
  # Key: kubernetes.io/role/internal-elb
  # Value: 1
  private_subnet_tags = {
    "kubernetes.io/cluster/dev-cluster" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }

}


# Data source query to get list of availability zones in the AWS region
data "aws_availability_zones" "my-azs" {
}



