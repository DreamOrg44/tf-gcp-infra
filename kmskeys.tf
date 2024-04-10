resource "google_kms_key_ring" "my_key_ring" {
  name     = "my-key-ring-7"
  location = var.region
}

resource "google_kms_crypto_key" "vm_crypto_key" {
  name       = "vm-crypto-key-7"
  key_ring   = google_kms_key_ring.my_key_ring.id
  purpose    = var.purpose
  rotation_period = "90000s"
}

resource "google_kms_crypto_key" "cloudsql_crypto_key" {
  name       = "cloudsql-crypto-key-7"
  key_ring   = google_kms_key_ring.my_key_ring.id
  purpose    = var.purpose
  rotation_period = "90000s"
}

resource "google_kms_crypto_key" "storage_crypto_key" {
  name       = "storage-crypto-key-7"
  key_ring   = google_kms_key_ring.my_key_ring.id
  purpose    = var.purpose
  rotation_period = "90000s"
}

# data "google_project_service_account" "storage_project_service_account" {
#   project = var.project_id
# }

# resource "google_project_iam_binding" "storage_decrypter_role" {
#   project = var.project_id
#   role    = "roles/cloudkms.cryptoKeyDecrypter"

#   members = [
#     "serviceAccount:${data.google_storage_project_service_account.storage_project_service_account.email}"
#   ]
# }
