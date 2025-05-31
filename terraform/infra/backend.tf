terraform {
  backend "gcs" { 
    bucket  = "ci_cd_bucket"
    prefix = "terraform/state/infra"
  }
}