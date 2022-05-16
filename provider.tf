terraform {
  required_providers {
    kind = {
      source  = "justenwalker/kind"
      version = "0.11.0-rc.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.5.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
provider "kubernetes" {
  config_context = kind_cluster.k8s-cluster.context
  config_path    = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_context = kind_cluster.k8s-cluster.context
    config_path    = "~/.kube/config"
  }
}
provider "kubectl" {
  config_context = kind_cluster.k8s-cluster.context
  config_path    = "~/.kube/config"
}
