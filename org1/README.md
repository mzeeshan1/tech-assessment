## Deployment Steps

### Required Tools
- **aws-cli**: Install from [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- **terraform**: Install from [Terraform Installation Guide](https://developer.hashicorp.com/terraform/downloads).

### 1. Set AWS Terraform User Credentials
**AWS Access Key ID** and **Secret Access Key** are provided with email. **Terraform** user has been configured with necessary permissions to access the s3 backend, dynamodb lock table and to create resources on AWS

Export the credentials as environment variables:
```bash
    export AWS_ACCESS_KEY_ID=<your-access-key-id>
    export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
```

### 2. Initializa backend
```
   terraform init
```

4. Apply terraform plan
The changes will be applied in two steps, first to create the necessary secret for datadog api and second step is to apply compete plan
```bash
    terraform apply -target=aws_secretsmanager_secret.datadog_keys -target=aws_secretsmanager_secret_version.datadog_keys
```
This will create the secret `datadog/keys` in aws secret manager. Next step is to manually add the right secret value and apply complete terraform plan

``` bash
    terraform apply
```


## Design Decisions
There were 3 important aspects considered for making design decisions i.e scalibility, security and high availablity
- Scalability was ensured by using karpenter as cluster autoscaler for EKS nodes and HPA for application
- High availability was ensured by using a minimum of 3 nodes for HPA, one in each availabilty zone. Topology spread constraints conditions
place the pods on each availability zone
- Security was considered during making design decisions like ensuring api keys are stored in a secret manager and not exposed in code. Access to cluster is limited to roles, which can be assumed by users. For example cluster is provided admin access to a role sre which can be limited
to be assumed by specific users only. Although there are some key aspects still missing for example api server has public access which can be limited
to private network.

## Timeline
There were lots of small steps involved in performing this task for example:
- IaC setup (backend, IAM roles etc), spinning up EKS cluster, Installing and setting up karpenter keeping scalablity and high availability in mind,
creating a helmchart for the application, configuring values, packaging and hosting the helmchart to deploy it in automated way, installing and configuring datadog agents and adding alerts and dashboard in datadog and documenting the provided solution . 
