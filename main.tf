terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_vpc_network" "net" {
  count       = 1
  name        = var.network_name
  folder_id   = var.folder_id
}

resource "yandex_vpc_subnet" "vpc_k8s" {
  name           = "K8S Zone"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_k8s]
  zone           = var.zone
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  network_id  = yandex_vpc_network.net[0].id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"] # The load balancer's address range
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [var.cidr_k8s]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = [var.cidr_k8s]
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
