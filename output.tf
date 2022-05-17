data "kubernetes_service" "istio-ingress" {
  metadata {
    name = "istio-ingress"
    namespace = kubernetes_namespace.istio-system.metadata[0].name
  }
  depends_on = [
    helm_release.istio-ingress
  ]
}
output "config_context" {
  value = kind_cluster.k8s-cluster.context
}
output "ingress_ip_address" {
  value = data.kubernetes_service.istio-ingress.status[0].load_balancer[0].ingress[0].ip
  depends_on = [
    helm_release.istio-ingress
  ]
}
output "storage_class" {
  value = "standard"
}