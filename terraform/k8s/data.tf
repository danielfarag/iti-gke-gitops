data "terraform_remote_state" "gke_cluster_state" {
  backend = "gcs"
  config = {
    bucket = "ci_cd_bucket" 
    prefix = "terraform/state/infra"     
  }
}
