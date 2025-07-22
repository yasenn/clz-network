terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

# ========
# Folders
# ========
resource "yandex_resourcemanager_folder" "net_folder" {
  cloud_id = var.yc_cloud_id
  name     = "net-folder"
}

resource "yandex_resourcemanager_folder" "folder_b" {
  cloud_id = var.yc_cloud_id
  name     = "folderb"
}

resource "yandex_resourcemanager_folder" "folder_d" {
  cloud_id = var.yc_cloud_id
  name     = "folderd"
}


resource "yandex_vpc_network" "shared_net" {
  count       = 1
  name        = var.network_name
  # folder_id   = var.yc_folder_id # теперь переменная с folder_id определяется при создании ресурса
  folder_id = yandex_resourcemanager_folder.net_folder.id
}

resource "yandex_vpc_subnet" "vpc_k8s" {
  name           = "k8s_zone"
  network_id     = yandex_vpc_network.shared_net[0].id
  v4_cidr_blocks = [var.cidr_k8s]
  zone           = var.zone
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  network_id  = yandex_vpc_network.shared_net[0].id

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

## cross folders subnets

resource "yandex_vpc_subnet" "subnet_net" {
  folder_id      = yandex_resourcemanager_folder.net_folder.id
  name           = "subnet-net"
  description    = "folder subnet - net"
  v4_cidr_blocks = ["10.1.11.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.shared_net[0].id
}

resource "yandex_vpc_subnet" "subnet_a" {
  folder_id      = yandex_resourcemanager_folder.folder_b.id
  name           = "subnet-b"
  description    = "folder subnet - b"
  v4_cidr_blocks = ["10.1.12.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.shared_net[0].id
}

resource "yandex_vpc_subnet" "subnet_d" {
  folder_id      = yandex_resourcemanager_folder.folder_d.id
  name           = "subnet-d"
  description    = "folder subnet-d"
  v4_cidr_blocks = ["10.1.13.0/24"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.shared_net[0].id
}

