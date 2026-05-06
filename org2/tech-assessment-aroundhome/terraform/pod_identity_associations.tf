module "cert_manager_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "cert-manager"

  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["*"]
  association_defaults = {
    namespace       = "cert-manager"
    service_account = "cert-manager"
  }
  associations = {
    ex-one = {
      cluster_name = module.eks.cluster_name
    }
  }


}

module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "external-dns"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["*"]
  association_defaults = {
    namespace       = "kube-system"
    service_account = "external-dns"
  }

  associations = {
    ex-one = {
      cluster_name = module.eks.cluster_name
    }
  }

}
