resource "kubernetes_manifest" "backend_app" {
  depends_on = [ kubernetes_secret.my_gcr_secret, kubernetes_secret.repo, kubernetes_secret.db_credentials ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "backend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "backend-node=us-central1-docker.pkg.dev/iti-gcp-course/docker/project1-backend-node:latest",
        "argocd-image-updater.argoproj.io/write-back-method": "git",
        "argocd-image-updater.argoproj.io/git-branch": "main",
        "argocd-image-updater.argoproj.io/backend-node.update-strategy": "newest-build",
        "argocd-image-updater.argoproj.io/backend-node.pull-secret": "pullsecret:argocd/my-gcr-secret",
        "argocd-image-updater.argoproj.io/write-back-target": "helmvalues:values.yaml",
        "argocd-image-updater.argoproj.io/backend-node.helm.image-tag": "image.tag",
        "argocd-image-updater.argoproj.io/backend-node.helm.image-name": "image.repository"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "git@github.com:danielfarag/iti-gke-gitops-capstone.git"
        targetRevision = "main"
        path           = "cd/backend"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}



resource "kubernetes_manifest" "frontend_app" {
  depends_on = [ kubernetes_manifest.backend_app ]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend-project"
      namespace = "argocd"
      annotations =  {
        "argocd-image-updater.argoproj.io/image-list": "frontend-node=us-central1-docker.pkg.dev/iti-gcp-course/docker/project1-frontend-node:latest",
        "argocd-image-updater.argoproj.io/write-back-method": "git",
        "argocd-image-updater.argoproj.io/git-branch": "main",
        "argocd-image-updater.argoproj.io/frontend-node.update-strategy": "newest-build",
        "argocd-image-updater.argoproj.io/frontend-node.pull-secret": "pullsecret:argocd/my-gcr-secret",
        "argocd-image-updater.argoproj.io/write-back-target": "helmvalues:values.yaml",
        "argocd-image-updater.argoproj.io/frontend-node.helm.image-tag": "image.tag",
        "argocd-image-updater.argoproj.io/frontend-node.helm.image-name": "image.repository"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "git@github.com:danielfarag/iti-gke-gitops-capstone.git"
        targetRevision = "main"
        path           = "cd/frontend"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}