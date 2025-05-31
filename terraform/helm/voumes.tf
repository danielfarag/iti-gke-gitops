resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Delete"

    storage_class_name = "manual"

    persistent_volume_source {
      gce_persistent_disk {
        pd_name = "jenkins-disk"
        fs_type = "ext4"
      }
    }
  }
}