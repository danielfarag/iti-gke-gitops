
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.6" 

  values = [
    file("values/argocd-values.yaml") 
  ]
}


resource "helm_release" "argocd-image-updater" {
  name       = "argocd-image-updater"
  namespace  = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.12.1" 

  values = [
    file("values/image-updater-values.yaml") 
  ]
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = "jenkins"
  create_namespace = true

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.8.48" 

  values = [
    file("values/jenkins-values.yaml") 
  ]
}