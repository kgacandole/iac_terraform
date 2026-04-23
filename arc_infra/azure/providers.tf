terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
    features {}
    use_oidc = true
}

provider "helm" {
  kubernetes = {
    host                   = module.kube_cluster.kube_cluster_host
    client_certificate     = module.kube_cluster.kube_cluster_client_certificate
    client_key             = module.kube_cluster.kube_cluster_client_key
    cluster_ca_certificate = module.kube_cluster.kube_cluster_ca_cert
  }
}

provider "kubernetes" {
  host                   = module.kube_cluster.kube_cluster_host
  client_certificate     = module.kube_cluster.kube_cluster_client_certificate
  client_key             = module.kube_cluster.kube_cluster_client_key
  cluster_ca_certificate = module.kube_cluster.kube_cluster_ca_cert
}
