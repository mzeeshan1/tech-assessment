data "tls_certificate" "gitlab" {
  url = "tls://gitlab.com:443"
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = "https://gitlab.com"
  client_id_list  = ["https://gitlab.com"]
  thumbprint_list = [data.tls_certificate.gitlab.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.gitlab.url}:sub"
      values   = ["project_path:zeeshan30/hello-world-app:ref_type:branch:ref:main"]
    }
  }
}

data "aws_iam_policy" "ecr_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role" "gitlab_ci" {
  name_prefix         = "GitLabCI"
  assume_role_policy  = data.aws_iam_policy_document.assume-role-policy.json
  managed_policy_arns = [data.aws_iam_policy.ecr_access.arn]
}
