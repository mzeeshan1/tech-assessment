################################################################################
# EKS
################################################################################

module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "~> 20.29.0"
  cluster_name                             = "tech-assessment-cluster"
  cluster_version                          = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  eks_managed_node_groups = {
    addons = {
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      capacity_type  = "SPOT"

    }
  }
  access_entries = {
    # One access entry with a policy associated
    sre = {
      principal_arn = "arn:aws:iam::841602633529:role/sre"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    dev = {
      principal_arn = "arn:aws:iam::841602633529:role/dev"
      policy_associations = {
        edit = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = ["app"]
          }
        }
      }
    },
    admin = {
      principal_arn = "arn:aws:iam::841602633529:user/zeeshan"
      policy_associations = {
        edit = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
  }
  tags = {
    Terraform = "true"
  }
}
