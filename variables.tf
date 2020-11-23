variable "region" {
  type    = string
  default = "us-east1"
}

variable "project_id" {
  type    = string
  default = "doc-cf-gke"
}

variable "cluster_name" {
  type    = string
  default = "devops-catalog"
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "billing_account_id" {
  type    = string
  default = "01752E-CE7D0E-CD5ED3"
}

variable "k8s_version" {
  type    = string
  default = "1.17.13-gke.2600"
}

variable "destroy" {
  type    = bool
  default = false
}
