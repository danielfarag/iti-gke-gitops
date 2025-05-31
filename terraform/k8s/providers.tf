provider "google" {
  project     = var.project_id
  region      = var.region
}

locals {
  access_token = data.terraform_remote_state.gke_cluster_state.outputs.access_token
  endpoint=data.terraform_remote_state.gke_cluster_state.outputs.endpoint
  cluster_ca_certificate=data.terraform_remote_state.gke_cluster_state.outputs.ca_certificate
}

provider "kubernetes" {
  host                   = "https://${local.endpoint}"
  token                  =  local.access_token
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
}