
# Terraform Helm Deployment for CI/CD Tools

This Terraform configuration automates the deployment of key CI/CD tools (ArgoCD, ArgoCD Image Updater, and Jenkins) onto a GKE (Google Kubernetes Engine) cluster using Helm charts.

## 🛠️ Overview

This module includes:

* **Helm releases** for:

  * `argo-cd`
  * `argocd-image-updater`
  * `jenkins`
* **GKE integration** via remote state for cluster credentials
* **Persistent Volume** creation for Jenkins
* **GCS backend** for Terraform state storage

---

## ☁️ Prerequisites

* Google Cloud Project with GKE and GCS access
* Existing GKE cluster (remote state must include: `endpoint`, `access_token`, `ca_certificate`)
* Persistent Disk named `jenkins-disk` already created in the same project/zone

---

## 📦 Tools Deployed

### 1. Argo CD

* Namespace: `argocd`
* Version: `5.46.6`
* Source: [Argo Helm](https://github.com/argoproj/argo-helm)

### 2. Argo CD Image Updater

* Namespace: `argocd`
* Version: `0.12.1`
* Enhances Argo CD by automating image updates

### 3. Jenkins

* Namespace: `jenkins`
* Version: `5.8.48`
* Jenkins uses a pre-created Persistent Volume backed by a GCE Persistent Disk

---

## ⚙️ Configuration

### Backend State

Stored in a GCS bucket:

```hcl
terraform {
  backend "gcs" {
    bucket = "ci_cd_bucket"
    prefix = "terraform/state/infra-helm"
  }
}
```

### GKE Credentials (via Remote State)

```hcl
data "terraform_remote_state" "gke_cluster_state" {
  backend = "gcs"
  config = {
    bucket = "ci_cd_bucket"
    prefix = "terraform/state/infra"
  }
}
```

---

## 🚀 Usage

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Review the execution plan:

   ```bash
   terraform plan
   ```

3. Apply the configuration:

   ```bash
   terraform apply
   ```

---

## 🧹 Cleanup

To destroy all Helm releases and resources created:

```bash
terraform destroy
```
