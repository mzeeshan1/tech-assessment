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
    coredns = {
      configuration_values = jsonencode({
        tolerations = [
          # Allow CoreDNS to run on the same nodes as the Karpenter controller
          # for use during cluster creation when Karpenter nodes do not yet exist
          {
            key    = "karpenter.sh/controller"
            value  = "true"
            effect = "NoSchedule"
          }
        ]
      })
    }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  eks_managed_node_groups = {
    addons = {
      instance_types = ["m5.large"]

      min_size     = 2
      max_size     = 2
      desired_size = 2

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }

      taints = {
        # The pods that do not tolerate this taint should run on nodes
        # created by Karpenter
        karpenter = {
          key    = "karpenter.sh/controller"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
  access_entries = {
    # One access entry with a policy associated
    sre = {
      principal_arn = "arn:aws:iam::533266993905:role/sre"
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
      principal_arn = "arn:aws:iam::533266993905:role/dev"
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
      principal_arn = "arn:aws:iam::533266993905:user/sosafe"
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
  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })

  tags = {
    Terraform = "true"
  }
}
