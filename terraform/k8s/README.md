# ArgoCD GitOps Deployment with Terraform

This project uses Terraform to configure a GitOps-based CI/CD pipeline on a GKE cluster using **ArgoCD** and **ArgoCD Image Updater**. It automates the deployment of both frontend and backend applications and manages private registry access and Git SSH credentials.

---

## 🚀 Features

* Deploys ArgoCD `Application` resources for frontend and backend apps.
* Automatically updates container image versions using ArgoCD Image Updater.
* Uses secrets for:

  * GCR (Google Container Registry) pull access
  * GitHub SSH access for private repo
  * Database credentials
* Uses a remote GCS backend to manage state files.
* Dynamically pulls credentials and GKE details from a separate Terraform state file.

---

## 🔧 Prerequisites

* A configured **GKE Cluster**
* A **GCS Bucket** for Terraform remote state (`ci_cd_bucket`)
* Terraform installed (`>=1.0`)
* Required Terraform state outputs from your infra project:

  * `access_token`
  * `endpoint`
  * `ca_certificate`
  * `gcr_pull_key_json`
  * `database_*`

---

## 🔐 Required Secrets

### 1. GitHub SSH Private Key

Set via Terraform variable: `github_privatekey`

### 2. GCR Pull Secret

Decoded from the GKE cluster state output (`gcr_pull_key_json`), used to authenticate Docker image pulls.

### 3. Database Credentials

Pulled from GKE cluster remote state and injected into the Kubernetes secret `db-credentials`.

---

## 🛠 Terraform Usage

### 1. Initialize

```bash
terraform init
```

### 2. Apply Configuration

```bash
terraform apply
```

> Ensure you provide the `github_privatekey` as a secure input or via a secure `.tfvars` file.

---

## 📦 Deployed Components

### ✅ Kubernetes Secrets

* `my-gcr-secret`: Docker pull secret (in `default` and `argocd` namespaces)
* `private-repo`: GitHub SSH credentials secret (in `argocd`)
* `db-credentials`: Database credentials secret

### ✅ ArgoCD Applications

* `backend-project`

  * Path: `cd/backend`
  * Image: `project1-backend-node`
* `frontend-project`

  * Path: `cd/frontend`
  * Image: `project1-frontend-node`
  * Depends on backend deployment

Both are:

* Synced automatically (`syncPolicy.automated`)
* Updated using ArgoCD Image Updater via Git commit to Helm values

---

## 📄 Notes

* This configuration assumes ArgoCD is installed in the `argocd` namespace.
* The repo must contain a Helm chart or Kustomize setup under `cd/backend` and `cd/frontend`.
* Ensure the ArgoCD Image Updater is installed and has access to write back to your GitHub repo.

---

## 🧪 Testing & Validation

After applying Terraform:

1. Check ArgoCD UI (`<your-argocd-server>`)
2. Validate that both apps are synced and healthy
3. Push a new image with updated tags and validate auto-update via Image Updater