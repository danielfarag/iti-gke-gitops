resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = "docker"
  description   = "My Docker repository"
  location      = var.region
  format        = "DOCKER"
}


resource "google_artifact_registry_repository_iam_member" "docker_repo_reader_binding" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gcr_pull.email}"
}
