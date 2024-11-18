locals {
  namespace = "karpenter"
}

################################################################################
# Controller & Node IAM roles, SQS Queue, Eventbridge Rules
################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.24"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true
  namespace             = "karpenter"

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = local.name
  create_pod_identity_association = true

  tags = local.tags
}

################################################################################
# Helm charts
################################################################################

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.0.2"
  wait             = false

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: karpenter.sh/controller
        operator: Exists
        effect: NoSchedule
    webhook:
      enabled: false
    EOT
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}


resource "kubernetes_manifest" "karpenter_node_class" {
  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = "default"
    }
    "spec" = {
      "amiSelectorTerms" = [
        {
          "alias" = "al2@latest"
        },
      ]
      "role" = local.name
      "securityGroupSelectorTerms" = [
        {
          "tags" = {
            "karpenter.sh/discovery" = local.name
          }
        },
      ]
      "subnetSelectorTerms" = [
        {
          "tags" = {
            "karpenter.sh/discovery" = local.name
          }
        },
      ]
      "tags" = {
        "karpenter.sh/discovery" = local.name
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = {
    "apiVersion" = "karpenter.sh/v1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "default"
    }
    "spec" = {
      "disruption" = {
        "consolidateAfter"    = "30s"
        "consolidationPolicy" = "WhenEmptyOrUnderutilized"
      }
      "limits" = {
        "cpu" = 1000
      }
      "template" = {
        "spec" = {
          "nodeClassRef" = {
            "group" = "karpenter.k8s.aws"
            "kind"  = "EC2NodeClass"
            "name"  = "default"
          }
          "requirements" = [
            {
              "key"      = "karpenter.k8s.aws/instance-category"
              "operator" = "In"
              "values" = [
                "c",
                "m",
              ]
            },
            {
              "key"      = "karpenter.k8s.aws/instance-cpu"
              "operator" = "In"
              "values" = [
                "4",
                "8",
              ]
            },
            {
              "key"      = "kubernetes.io/arch"
              "operator" = "In"
              "values" = [
                "amd64",
              ]
            },
            {
              "key"      = "topology.kubernetes.io/zone"
              "operator" = "In"
              "values"   = local.azs
            },
            {
              "key"      = "karpenter.k8s.aws/instance-generation"
              "operator" = "Gt"
              "values" = [
                "2",
              ]
            },
          ]
        }
      }
    }
  }
}
