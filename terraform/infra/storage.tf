
resource "google_compute_disk" "jenkins_disk" {
  name  = "jenkins-disk"
  size  = 10
  type  = "pd-standard"
  zone  = "us-central1-b"
}