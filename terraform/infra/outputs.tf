data "google_client_config" "default" {}


output "endpoint" {
  value = module.gke.endpoint
}

output "ca_certificate" {
  value = module.gke.ca_certificate
  sensitive = true
}

output "access_token" {
  value = data.google_client_config.default.access_token
  sensitive = true
}


output "instance_connection_name" {
  description = "The connection name of the Cloud SQL instance for connecting via Cloud SDK."
  value       = google_sql_database_instance.main_instance.connection_name
}

output "database_private_ip" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.main_instance.private_ip_address
}

output "database_name" {
  description = "The name of the created database."
  value       = google_sql_database.my_database.name
}

output "database_user" {
  description = "The username for the database."
  value       = google_sql_user.db_user.name
}

output "database_password" {
  description = "The username for the database."
  value       = var.db_password
  sensitive = true
}

output "gcr_pull_key_json" {
  value     = google_service_account_key.gcr_pull_key.private_key
  sensitive = true
}
