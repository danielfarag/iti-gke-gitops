variable "project_id" {
  type = string
  default = "iti-gcp-course"
}

variable "vpc_name" {
  type = string
  default = "cluster"
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "zones" {
  type = list(string)
  default = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "cluster_name" {
  type = string
  default = "iti-cluster"
}


variable "db_user" {
  type = string
  default = "user"
}
variable "db_password" {
  type = string
  default = "password"
}
variable "db_name" {
  type = string
  default = "project"
}