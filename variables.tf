variable "zone" {
  type        = string
}

variable "yc_cloud_id" {
  type        = string
}

variable "yc_folder_id" {
  type        = string
}

variable "network_name" {
  type        = string
}

variable "cidr_k8s" {
  type        = string
  default     = "10.1.0.0/16"
}
