
resource "helm_release" "datadog_agent" {
  name             = "datadog-agent"
  chart            = "datadog"
  repository       = "https://helm.datadoghq.com"
  version          = "3.80.0"
  namespace        = "monitoring"
  create_namespace = true
  set_sensitive {
    name  = "datadog.apiKey"
    value = local.datadog_api_key
  }
  set_sensitive {
    name  = "datadog.appKey"
    value = local.datadog_app_key
  }
  values = [
    file("datadog_customVal.yaml")
  ]
}

resource "aws_secretsmanager_secret" "datadog_keys" {
  name        = "datadog/keys"
  description = "Datadog API and App Keys for Helm Chart"
}

resource "aws_secretsmanager_secret_version" "datadog_keys" {
  secret_id = aws_secretsmanager_secret.datadog_keys.id

  secret_string = jsonencode({
    api_key = "changeme"
    app_key = "changeme"
  })
  lifecycle {
    ignore_changes = [secret_string]
  }

}

data "aws_secretsmanager_secret" "datadog_keys" {
  name = aws_secretsmanager_secret.datadog_keys.name
}

data "aws_secretsmanager_secret_version" "datadog_keys_version" {
  secret_id = data.aws_secretsmanager_secret.datadog_keys.id
}

locals {
  datadog_secrets = jsondecode(data.aws_secretsmanager_secret_version.datadog_keys_version.secret_string)
  datadog_api_key = local.datadog_secrets.api_key
  datadog_app_key = local.datadog_secrets.app_key
}
