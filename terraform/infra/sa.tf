resource "google_service_account" "gcr_pull" {
  account_id   = "gcr-pull"
  display_name = "Pull From Google Artifact"
}


resource "google_project_iam_member" "gcr_pull_artifact_role" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gcr_pull.email}"
}

resource "google_service_account_key" "gcr_pull_key" {
  service_account_id = google_service_account.gcr_pull.name
  keepers = {
    service_account_email = google_service_account.gcr_pull.email
  }
}
