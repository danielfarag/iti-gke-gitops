# 🚀 GCP Infrastructure & Application Deployment with Terraform and CI/CD

This Terraform project automates the provisioning of core infrastructure components on **Google Cloud Platform (GCP)** to support **CI/CD workflows**, including:

* A **VPC** with custom subnetting
* **Private IP** SQL instance
* **GKE (Google Kubernetes Engine)** cluster
* **Docker Artifact Registry**
* **Service accounts and IAM roles**
* **Storage backend for Terraform state**

---

## 📁 Project Structure

This Terraform configuration includes the following components:

### 🔧 Core Infrastructure

* **VPC & Subnet** with secondary IP ranges for GKE
* **Private IP range** reserved for VPC peering
* **Service Networking** connection for private SQL

### 🗄️ Google Cloud SQL

* MySQL 8.0 with private networking
* Backup configuration
* Enforced private IP communication

### ☸️ GKE Cluster

* Regional GKE cluster using Terraform GKE module
* Node pool configuration with autoscaling and spot instances
* Tags, taints, labels, and metadata support

### 🐳 Artifact Registry

* Private Docker registry
* IAM binding for read access by Jenkins or CI agents

### 🔐 Service Accounts

* Service account with permission to pull images from the Docker registry
* Encrypted service account key exposed via Terraform output (sensitive)

### 💾 Jenkins Persistent Disk

* Compute Engine disk for Jenkins stateful data

---

## 📦 Requirements

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* A GCP Project with billing enabled
* Enabled APIs:

  * `compute.googleapis.com`
  * `container.googleapis.com`
  * `sqladmin.googleapis.com`
  * `servicenetworking.googleapis.com`
  * `artifactregistry.googleapis.com`

---

## 📥 Backend Setup

Terraform state is stored in a **GCS bucket**:

```hcl
terraform {
  backend "gcs" {
    bucket = "ci_cd_bucket"
    prefix = "terraform/state/infra"
  }
}
```

---

## 🔑 Variables

```hcl
project_id     = "iti-gcp-course"
region         = "us-central1"
zones          = ["us-central1-a", "us-central1-b", "us-central1-c"]
vpc_name       = "cluster"
cluster_name   = "iti-cluster"
db_user        = "user"
db_password    = "password"
db_name        = "project"
```

Override them by defining a `terraform.tfvars` file.

---

## ▶️ Usage

1. **Initialize Terraform**

   ```bash
   terraform init
   ```

2. **Preview the execution plan**

   ```bash
   terraform plan
   ```

3. **Apply the configuration**

   ```bash
   terraform apply
   ```

---

## 🔐 Outputs

* GKE cluster endpoint, token, and CA certificate
* Cloud SQL instance name, private IP, and credentials
* Artifact Registry access credentials for CI tools

All sensitive data (e.g., tokens and passwords) are marked as sensitive and will not display in plaintext output.

---

## 🔄 CI/CD Integration Ideas

* Store Docker images in Artifact Registry
* Use service account key to authenticate CI tool (GitHub Actions) to pull images
* Deploy applications to GKE using output values
---
