resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = var.CILIUM_VERSION
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
  hubble:
    ui:
      enabled: true
    relay:
      enabled: true
  EOF
  ]
  depends_on = [
    kind_cluster.k8s-cluster
  ]
}

resource "kubectl_manifest" "hubble-router" {
  for_each = {
    hubble-gateway = <<EOF
    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: hubble
    spec:
      selector:
        istio: ingressgateway
      servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
        - "hubble.${data.kubernetes_service.istio-ingressgateway.status[0].load_balancer[0].ingress[0].ip}.nip.io"
    EOF
    hubble-virtaulservice = <<EOF
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: hubble
    spec:
      hosts:
      - "hubble.${data.kubernetes_service.istio-ingressgateway.status[0].load_balancer[0].ingress[0].ip}.nip.io"
      gateways:
      - hubble
      http:
      - route:
        - destination:
            host: hubble-ui.${helm_release.cilium.namespace}.svc.cluster.local
            port:
              number: 80
    EOF
  }
  yaml_body = each.value
  override_namespace = helm_release.cilium.namespace
}
