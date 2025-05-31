
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "main_instance" {
  database_version = "MYSQL_8_0" 
  name             = "database" 
  region           = "us-central1"               
  depends_on = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = false
  settings {
    deletion_protection_enabled=false
    tier = "db-f1-micro" 
    ip_configuration {
      ipv4_enabled         = false
      private_network                               = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }

    
    backup_configuration {
      enabled            = true
      start_time         = "03:00" 
      binary_log_enabled = false   
    }
    
    disk_autoresize = true
    disk_size       = 20 
    disk_type       = "PD_SSD" 
  }

  
  
  root_password = var.db_password 
}



resource "google_sql_database" "my_database" {
  name     = var.db_name 
  instance = google_sql_database_instance.main_instance.name
  charset  = "utf8mb4"
  collation = "utf8mb4_unicode_ci" 
}



resource "google_sql_user" "db_user" {
  name     = var.db_user 
  host     = "%"
  instance = google_sql_database_instance.main_instance.name
  password_wo = var.db_password 
}

