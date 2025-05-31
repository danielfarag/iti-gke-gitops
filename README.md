## Automated Infrastructure and Application Deployment on GCP using Terraform, Github Actions and ArgoCD

This repository contains Terraform configurations for deploying a Google Kubernetes Engine (GKE) cluster, its supporting infrastructure (VPC, Cloud SQL, Artifact Registry), and essential applications (ArgoCD, ArgoCD Image Updater) using Helm. It also configures ArgoCD Applications for backend and frontend services.

-----

## Prerequisites

Before you begin, ensure you have the following:

  * **Google Cloud Project:** A Google Cloud project with billing enabled.
  * **Terraform:** [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html).
  * **`gcloud` CLI:** [Install and initialize the Google Cloud SDK](https://www.google.com/search?q=https://cloud.google.com/sdk/docs/install-and-initialize).
  * **Service Account Key:** A service account with the necessary permissions to create and manage resources in your Google Cloud project. It's recommended to use Workload Identity or user impersonation for production environments. For development, you can authenticate via `gcloud auth application-default login`.
  * **Google Cloud Storage Bucket:** A GCS bucket for storing Terraform state files. The configurations expect a bucket named `ci_cd_bucket`. Create it if it doesn't exist:
    ```bash
    gsutil mb gs://ci_cd_bucket
    ```
  * **GitHub Personal Access Token or SSH Key:** If your GitHub repository for ArgoCD applications is private, you'll need a GitHub SSH private key (provided as a variable `github_privatekey` in `infra-apps`).
  * **GitHub Personal Access Token or SSH Key:** If your GitHub repository for ArgoCD applications is private, you'll need a GitHub SSH private key (provided as a variable `github_privatekey` in `infra-apps`).
  * **GitHub Secrets and Variables:** For the GitHub Actions workflows, ensure you have the following configured in your GitHub repository:
      * **Secrets:**
          * `GOOGLE_CREDENTIALS`: JSON key for a Google Cloud service account with permissions to manage your GCP resources (e.g., `roles/owner` for simplicity, but more granular roles are recommended for production).
          * `PRIVATE_KEY`: The SSH private key to access your private GitHub repository (used by ArgoCD).
      * **Variables:**
          * `project_id`: Your Google Cloud project ID.
          * `region`: The Google Cloud region for resource deployment.
          * `cluster_name`: The name of your GKE cluster.

-----
## GitHub Actions Workflows

This repository includes several GitHub Actions workflows to automate the build, push, and deployment processes.

### 1\. Backend Pipeline (`.github/workflows/backend-pipeline.yaml`)

  * **Trigger:** On `push` to the `main` branch when changes occur within the `backend/**` path.
  * **Purpose:** Builds the Docker image for the backend application and pushes it to Google Artifact Registry.
  * **Steps:**
      * Checks out the repository.
      * Sets up Docker Buildx.
      * Authenticates to GCP using `GOOGLE_CREDENTIALS` secret.
      * Configures Docker to push to Google Artifact Registry.
      * Builds and tags the backend Docker image with both `latest` and `github.sha`.
      * Pushes the images to Google Artifact Registry.

### 2\. Frontend Pipeline (`.github/workflows/frontend-pipeline.yaml`)

  * **Trigger:** On `push` to the `main` branch when changes occur within the `frontend/**` path.
  * **Purpose:** Builds the Docker image for the frontend application and pushes it to Google Artifact Registry.
  * **Steps:**
      * Checks out the repository.
      * Sets up Docker Buildx.
      * Authenticates to GCP using `GOOGLE_CREDENTIALS` secret.
      * Configures Docker to push to Google Artifact Registry.
      * Builds and tags the frontend Docker image with both `latest` and `github.sha`.
      * Pushes the images to Google Artifact Registry.

### 3\. Infrastructure Pipeline (`.github/workflows/infra-pipeline.yaml`)

  * **Trigger:**
      * On `workflow_dispatch` (manual trigger) with an `action` input (`apply` or `destroy`).
      * On `push` to the `main` branch when changes occur within the `terraform/infra/**` path.
  * **Purpose:** Manages the core GCP infrastructure (VPC, GKE, Cloud SQL, Artifact Registry) using the `infra` Terraform module.
  * **Steps:**
      * Checks out the repository.
      * Sets up Terraform.
      * Defines Terraform variables (`project_id`, `region`, `cluster_name`) from GitHub Actions variables.
      * Runs `terraform init` for the `infra` module.
      * Runs `terraform apply -auto-approve` for the `infra` module on `push` or `apply` action.
      * Includes `terraform destroy` steps for `k8s`, `helm`, and `infra` modules when `destroy` action is selected. **Note:** The destroy steps are ordered from innermost to outermost dependency (k8s -\> helm -\> infra).

### 4\. Infrastructure Helm Pipeline (`.github/workflows/infra-helm-pipeline.yaml`)

  * **Trigger:**
      * On `workflow_dispatch` (manual trigger) with an `action` input (`apply` or `destroy`).
      * On `push` to the `main` branch when changes occur within the `terraform/helm/**` path.
  * **Purpose:** Manages the Helm chart deployments (ArgoCD, ArgoCD Image Updater, Jenkins) using the `infra-helm` Terraform module. This workflow depends on the `infra` job from the Infrastructure Pipeline.
  * **Steps:**
      * Checks out the repository.
      * Sets up Terraform.
      * Defines Terraform variables (`project_id`, `region`) from GitHub Actions variables.
      * Runs `terraform init` for the `helm` module.
      * Runs `terraform apply -auto-approve` for the `helm` module on `push` or `apply` action.
      * Includes `terraform destroy` steps for `k8s` and `helm` modules when `destroy` action is selected.

### 5\. Infrastructure K8s Pipeline (`.github/workflows/infra-k8s-pipeline.yaml`)

  * **Trigger:**
      * On `workflow_dispatch` (manual trigger) with an `action` input (`apply` or `destroy`).
      * On `push` to the `main` branch when changes occur within the `terraform/k8s/**` path.
  * **Purpose:** Manages the Kubernetes secrets and ArgoCD Application deployments using the `infra-apps` Terraform module (referred to as `k8s` in the workflow for historical reasons). This workflow depends on the `helm` job from the Infrastructure Helm Pipeline.
  * **Steps:**
      * Checks out the repository.
      * Sets up Terraform.
      * Defines Terraform variables (`github_privatekey`) from GitHub Actions secrets.
      * Runs `terraform init` for the `k8s` module.
      * Runs `terraform apply -auto-approve` for the `k8s` module on `push` or `apply` action.
      * Includes a `terraform destroy` step for the `k8s` module when `destroy` action is selected.
---

## Deployment Steps

This deployment is broken down into three distinct Terraform applies to manage dependencies and state effectively.

```bash
make start
```
## This step will provision:

### 1\. Core Infrastructure (`terraform/infra`)

  * A **VPC Network** and **Subnet** for your GKE cluster.
  * A **GKE Cluster** with a default node pool.
  * A **Cloud SQL (MySQL) instance** and a dedicated database and user.
  * A **Google Artifact Registry (Docker)** repository for storing container images.
  * A **Service Account** with permissions to pull from Artifact Registry.

-----

### 2\. Deploy Helm Applications  (`terraform/hekm`)

This step will deploy:

  * **ArgoCD:** A declarative GitOps continuous delivery tool for Kubernetes.
  * **ArgoCD Image Updater:** An ArgoCD extension that automatically updates container images in Git based on new image tags.

**Note:** Ensure you have `values/argocd-values.yaml`, `values/image-updater-values.yaml`, and `values/jenkins-values.yaml` populated with your desired configurations for these Helm charts.

-----

### 3\. Deploy Kubernetes Applications (`terraform/k8s`)

Finally, deploy the backend and frontend applications using ArgoCD's Application custom resource. Navigate to the `infra-apps` directory:

This step will create:

  * **Kubernetes Secrets:**
      * A secret for ArgoCD to access your private GitHub repository (`private-repo`).
      * Secrets (`my-gcr-secret`) for GCR/Artifact Registry authentication, allowing Kubernetes pods to pull images from your private Docker repository.
      * A secret (`db-credentials`) containing the Cloud SQL database connection details for your applications.
  * **ArgoCD Applications:**
      * `backend-project`: An ArgoCD application pointing to your backend service's Helm chart in Git.
      * `frontend-project`: An ArgoCD application pointing to your frontend service's Helm chart in Git.

These ArgoCD applications are configured to use `argocd-image-updater` for automated image updates, writing back to your Git repository.

-----

## Post-Deployment

After successfully running all Terraform modules, you'll have a running GKE cluster with essential CI/CD tools and your applications managed by ArgoCD.

  * **Access ArgoCD:**
      * Retrieve the ArgoCD server's external IP or configure ingress to access its UI.
      * Initial login credentials for ArgoCD can be found in the ArgoCD documentation.
  * **Connect to Cloud SQL:**
      * You can connect to your Cloud SQL instance using the `gcloud sql connect` command or by configuring your applications to use the private IP address.

-----

## Variables

Each module has its own `variables.tf` file. You can override the default values by providing a `terraform.tfvars` file in each module directory or by passing them via the command line (`-var="key=value"`).

**Common Variables:**

  * `project_id`: Your Google Cloud project ID.
  * `region`: The Google Cloud region for resource deployment.
  * `vpc_name`: The name of the VPC network.
  * `zones`: List of zones for GKE nodes.
  * `cluster_name`: The name of your GKE cluster.
  * `db_user`: Database username for Cloud SQL.
  * `db_password`: Database password for Cloud SQL. **Sensitive information, use caution\!**
  * `db_name`: Database name for Cloud SQL.
  * `github_privatekey`: (In `infra-apps`) SSH private key for accessing your private GitHub repository for ArgoCD. **Sensitive information, use caution\!**

-----

## State Management

Terraform state is stored remotely in Google Cloud Storage buckets for collaboration and consistency. Each module uses a different prefix within the `ci_cd_bucket`:

  * `infra`: `gs://ci_cd_bucket/terraform/state/infra`
  * `infra-helm`: `gs://ci_cd_bucket/terraform/state/infra-helm`
  * `infra-apps`: `gs://ci_cd_bucket/terraform/state/infra-apps`

-----

## Important Notes

  * **Security:** Always review the generated Terraform plan before applying. For production environments, consider using [Terraform Cloud](https://cloud.hashicorp.com/) or similar tools for state management, remote operations, and access control. Manage sensitive variables (like `db_password` and `github_privatekey`) securely, e.g., using Google Secret Manager or environment variables with CI/CD pipelines.

  * **Cleanup:** To destroy all deployed resources, navigate to each module directory in reverse order of deployment and run `terraform destroy`.

    ```bash
    make clean
    ```

    **Use `terraform destroy` with extreme caution as it permanently deletes resources.**