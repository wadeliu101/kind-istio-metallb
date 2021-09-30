terraform {
  required_providers {
    kind = {
      source  = "justenwalker/kind"
      version = "0.11.0-rc.1"
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
