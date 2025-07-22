output "k8s_vpc_id" {
  value       = yandex_vpc_subnet.vpc_k8s.id
}

output "k8s_sg_id" {
  value       = yandex_vpc_security_group.regional-k8s-sg.id
}

output "k8s_net_id" {
  value       = yandex_vpc_network.shared_net.0.id
}
