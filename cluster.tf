resource "kind_cluster" "k8s-cluster" {
  name   = "k8s-cluster"
  image  = "kindest/node:v${var.KIND_VERSION}"
  config = var.KIND_CONFIG
}
