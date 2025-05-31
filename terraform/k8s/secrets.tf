resource "kubernetes_secret" "repo" {
  metadata {
    name      = "private-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name = "backend"
    type = "git"
    url  = "git@github.com:danielfarag/iti-gke-gitops-capstone.git"
    sshPrivateKey = var.github_privatekey
  }

  type = "Opaque"
}


resource "kubernetes_secret" "my_gcr_secret" {
  count = 2
  metadata {
    name      = "my-gcr-secret"
    namespace = element(["default", "argocd"], count.index)
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "us-central1-docker.pkg.dev" = {
          username = "_json_key"
          password = base64decode(data.terraform_remote_state.gke_cluster_state.outputs.gcr_pull_key_json)
          email    = "danielfarag146@gmail.com"
          auth     = base64encode("_json_key:${base64decode(data.terraform_remote_state.gke_cluster_state.outputs.gcr_pull_key_json)}")
        }
      }
    })
  }
}



resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
  }
  data = {
    DB_HOST: data.terraform_remote_state.gke_cluster_state.outputs.database_private_ip
    DB_NAME: data.terraform_remote_state.gke_cluster_state.outputs.database_name
    DB_USER: data.terraform_remote_state.gke_cluster_state.outputs.database_user
    DB_PASSWORD: data.terraform_remote_state.gke_cluster_state.outputs.database_password
  }
}
