# Loading K8s dependency module for EKS module

provider "kubernetes" {
  # below command deprecated
  # load_config_file       = false
  host                   = data.aws_eks_cluster.my-eks-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.my-eks-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-eks-cluster.certificate_authority.0.data)

# additional commands to support latest module
#  exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.my-eks.cluster_id]
#   }

}

# Query created EKS cluster for k8s provider config

data "aws_eks_cluster" "my-eks-cluster" {
  name = module.my-eks.cluster_id
}


data "aws_eks_cluster_auth" "my-eks-cluster" {
  name = module.my-eks.cluster_id
}

# Module section to create EKS cluster - EC2 instances as worker nodes

module "my-eks" {
  source  = "terraform-aws-modules/eks/aws"
#   version = "13.2.1"
  # insert the 7 required variables here


  # Name of the EKS cluster
  cluster_name = "dev-cluster"

  # Kubernetes version to use for the EKS cluster. 
  cluster_version = var.cluster_version

  # VPC where the cluster and workers will be deployed.
  vpc_id = module.my-vpc.vpc_id

  # A list of subnets to place the EKS cluster and workers within.
  # Following is deprecated in new EKS module
  # subnets = module.my-vpc.private_subnets

  subnet_ids = module.my-vpc.private_subnets

  # Worker nodes configuration-EC2 instances
  # Follwing worker_group is deprecated in latest EKS module
    #   worker_groups = [
    #     {
    #       name                 = "worker-1"
    #       instance_type        = var.instance_type1
    #       asg_desired_capacity = 1

    #     },
    #     {
    #       name                 = "worker-2"
    #       instance_type        = var.instance_type2
    #       asg_desired_capacity = 1
    #     }
    #   ]

    #   tags = {
    #     environment = "dev"
    #   }


  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t2.micro"
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 2
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.micro"
            weighted_capacity = "1"
           }
        #   {
        #     instance_type     = "t2.small"
        #     weighted_capacity = "1"
        #   },
        ]
      }
    }
  }

}