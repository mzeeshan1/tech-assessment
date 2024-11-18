resource "helm_release" "app" {
  name             = "app"
  chart            = "app"
  repository       = "https://mzeeshan1.github.io/helmcharts/"
  version          = "0.1.0"
  namespace        = "app"
  create_namespace = true
  values = [
    file("app_customVal.yaml")
  ]
}
