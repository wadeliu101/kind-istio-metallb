resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  namespace        = "kube-system"
  version          = var.CILIUM_VERSION
  values = [
    <<-EOF
  nodeinit:
    enabled: true
  kubeProxyReplacement: partial
  hostServices:
    enabled: false
  externalIPs:
    enabled: true
  nodePort:
    enabled: true
  hostPort:
    enabled: true
  bpf:
    masquerade: false
  image:
    pullPolicy: IfNotPresent
  ipam:
    mode: kubernetes
  EOF
  ]
  depends_on = [
    kind_cluster.k8s-cluster
  ]
}
