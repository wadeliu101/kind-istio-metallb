variable "ISTIO_VERSION" {
  type = string
  default = "1.13.3"
}
variable "KIND_NAME" {
  type = string
  default = "k8s-cluster"
}
variable "KIND_VERSION" {
  type = string
  default = "1.23.6"
}
variable "METALLB_VERSION" {
  type = string
  default = "0.12.1"
}
variable "KIND_CONFIG" {
  type = string
  default = <<-EOF
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
      extraPortMappings:
      - containerPort: 31151
        hostPort: 15021
        protocol: TCP
      - containerPort: 32041
        hostPort: 80
        protocol: TCP
      - containerPort: 31236
        hostPort: 443
        protocol: TCP
    - role: worker
    - role: worker
    networking:
      disableDefaultCNI: true
  EOF
}
variable "ISTIO_INGRESS_CONFIG" {
  type = string
  default = <<-EOF
  service:
    type: LoadBalancer
    ports:
    - name: status-port
      nodePort: 31151
      port: 15021
      protocol: TCP
      targetPort: 15021
    - name: http2
      nodePort: 32041
      port: 80
      protocol: TCP
      targetPort: 80
    - name: https
      nodePort: 31236
      port: 443
      protocol: TCP
      targetPort: 443
  nodeSelector:
    ingress-ready: "true"
  tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
  EOF
}
variable "CILIUM_VERSION" {
  type = string
  default = "1.11.3"
}