resource "kind_cluster" "k8s-cluster" {
  name   = var.KIND_NAME
  image  = "kindest/node:v${var.KIND_VERSION}"
  config = yamlencode(yamldecode(
  <<-EOF
    ${var.KIND_CONFIG}
    networking:
      disableDefaultCNI: true
  EOF
  ))
}
