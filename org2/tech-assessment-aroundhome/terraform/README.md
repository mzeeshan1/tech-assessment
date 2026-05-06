# Terraform

# Deployment steps
Requires access credentials for arn:aws:iam::841602633529:user/terraform. 
Once credentials are set
```bash
terraform init
terraform apply
```

# Resources
- EKS Cluster
- VPC
- ECR repositories
- POD Identity assocations for addons like cert-manager, external-dns
- OIDC, to push images/charts from gitlab ci to ECR
 

# TODO
- Configure variables to get a more modular functionality and make cluster name, region, vpc subnets, worker group configs, cluster version etc configurable
- remove cluster creator admin access
- make api server private and deal with implication that brings
