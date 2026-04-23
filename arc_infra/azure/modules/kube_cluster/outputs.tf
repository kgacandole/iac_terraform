output "kube_cluster_host" {
    value = azurerm_kubernetes_cluster.arc_cluster.kube_config.0.host
}

output "kube_cluster_client_certificate" {
    value = base64decode(azurerm_kubernetes_cluster.arc_cluster.kube_config.0.client_certificate)
}

output "kube_cluster_client_key" {
    value = base64decode(azurerm_kubernetes_cluster.arc_cluster.kube_config.0.client_key)
}

output "kube_cluster_ca_cert" {
    value = base64decode(azurerm_kubernetes_cluster.arc_cluster.kube_config.0.cluster_ca_certificate)
}