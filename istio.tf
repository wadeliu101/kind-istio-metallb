resource "null_resource" "download_istio" {
  triggers = {
    ISTIO_VERSION = var.ISTIO_VERSION
  }
  provisioner "local-exec" {
    command = "curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${self.triggers.ISTIO_VERSION} sh -"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -r ${path.root}/istio-${self.triggers.ISTIO_VERSION}"
  }
  depends_on = [
    helm_release.metallb
  ]
}
resource "kubernetes_namespace" "istio-operator" {
  metadata {
    annotations = {
      name                             = "istio-operator"
      "meta.helm.sh/release-name"      = "istio-operator"
      "meta.helm.sh/release-namespace" = "istio-operator"
    }
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    name = "istio-operator"
  }
  depends_on = [null_resource.download_istio]
}
resource "helm_release" "istio-operator" {
  name            = "istio-operator"
  repository      = "${path.root}/istio-${var.ISTIO_VERSION}/manifests/charts"
  chart           = "istio-operator"
  namespace       = kubernetes_namespace.istio-operator.metadata[0].name
  cleanup_on_fail = true
}
resource "kubernetes_namespace" "istio-system" {
  metadata {
    annotations = {
      name = "istio-system"
    }
    name = "istio-system"
  }
  depends_on = [helm_release.istio-operator]
}
resource "kubectl_manifest" "istio-profile" {
  yaml_body = var.ISTIO_PROFILE
  override_namespace = kubernetes_namespace.istio-system.metadata[0].name
  depends_on = [
    helm_release.istio-operator
  ]
}
resource "time_sleep" "wait_istio_ready" {
  create_duration = "120s"
  provisioner "local-exec" {
    command = "kubectl --context ${kind_cluster.k8s-cluster.context} wait deployment --all --timeout=-1s --for=condition=Available -n ${kubernetes_namespace.istio-system.metadata[0].name}"
  }
  depends_on = [
    kubectl_manifest.istio-profile
  ]
}