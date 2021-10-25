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
resource "local_file" "istio-profile" {
  content = var.ISTIO_PROFILE
  filename = "${path.root}/configs/istio-profile.yaml"
  provisioner "local-exec" {
    command = "kubectl apply -f ${self.filename} -n ${kubernetes_namespace.istio-system.metadata[0].name}"
  }
  depends_on = [
    helm_release.istio-operator
  ]
}
resource "time_sleep" "wait_istio_ready" {
  create_duration = "30s"
  provisioner "local-exec" {
    command = "kubectl wait deployment --all --timeout=-1s --for=condition=Available -n ${kubernetes_namespace.istio-system.metadata[0].name}"
  }
  depends_on = [
    local_file.istio-profile
  ]
}