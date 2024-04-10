resource "google_service_account" "instance_template_account" {
  account_id   = "instance-template-account"
  display_name = "VM Instance Template Service Account"
}

resource "google_service_account" "gcf_sa" {
  account_id   = "gcf-sa"
  display_name = "GCF Service Account"
}

resource "google_project_service_identity" "cloudsql_sa" {
  project  = var.project_id
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.cloudsql_crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.cloudsql_sa.email}",
  ]
}




#checkHere
resource "google_project_iam_member" "grant_kms_role_to_storage_service_account" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyDecrypter"
  member  = "serviceAccount:service-1050850969947@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "cloudsql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  
  members = [
    #   "serviceAccount:instance-template-account@${var.project_id}.iam.gserviceaccount.com",
      "serviceAccount:service-1050850969947@gs-project-accounts.iam.gserviceaccount.com",
  ]
}


resource "google_project_iam_member" "vm_instance_member" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:instance-template-account@${var.project_id}.iam.gserviceaccount.com"
#   member  = "serviceAccount:instance-template-account@${var.project_id}.iam.gserviceaccount.com"
  #checkHere
}

resource "google_project_iam_binding" "writer_config_monitor" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:instance-template-account@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "writer_metric_monitor" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:instance-template-account@${var.project_id}.iam.gserviceaccount.com",
  ]
}