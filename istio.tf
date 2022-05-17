resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}
resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = var.ISTIO_VERSION
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
}
resource "helm_release" "istio-istiod" {
  name       = "istio-istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = var.ISTIO_VERSION
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  depends_on = [
    helm_release.istio-base
  ]
}
resource "helm_release" "istio-ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = var.ISTIO_VERSION
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  values = [
    <<-EOF
    ${var.ISTIO_INGRESS_CONFIG}
    EOF
  ]
  depends_on = [
    helm_release.istio-istiod
  ]
}
