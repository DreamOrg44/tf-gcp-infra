provider "google"{ 
  #credentials = file("<path-to-your-service-account-key.json>")
  project     = var.project_id
  region      = var.region
}

# Create VPC
resource "google_compute_network" "mainvpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
  delete_default_routes_on_create = true
}

# Create Subnets
resource "google_compute_subnetwork" "subnet_1" {
  name          = var.subnetwork_name_1
  ip_cidr_range = var.subnetwork_ip_cidr_range_1
  region        = var.region
  network       = google_compute_network.mainvpc.name
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = var.subnetwork_name_2
  ip_cidr_range = var.subnetwork_ip_cidr_range_2
  region 	= var.region
  network       = google_compute_network.mainvpc.name
  private_ip_google_access = true
}

# Add Route for webapp subnet
resource "google_compute_route" "subnet_route" {
  name         = var.route_name
  network      = google_compute_network.mainvpc.self_link
  dest_range   = var.dest_range
  next_hop_gateway = var.next_hop_gateway

}
# Create Firewall Rule
resource "google_compute_firewall" "firewall" {
  name    = var.firewall_name
  network = google_compute_network.mainvpc.name

  allow {
    protocol = var.firewall_protocol
    ports    = [var.application_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp"]
}

#Create Google Compute Address For Compute Instance Access
# resource "google_compute_address" "internal_ip" {
#   name   = "internal-ip"
#   region = var.region
# }


# Create Compute Engine Instance
resource "google_compute_instance" "webapp_instance" {
  name         = var.compute_instance
  machine_type = "e2-standard-2"
  zone= var.zone
  depends_on=[google_compute_network.mainvpc, google_service_account.log_account]

  boot_disk {
    initialize_params {
      image = var.custom_image
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.self_link
	access_config {
      	# nat_ip = google_compute_address.internal_ip.address
    	}
  }
   metadata = {
    db_name     = google_sql_database.webapp_database.name
    db_user     = google_sql_user.webapp_user.name
    db_password = random_password.webapp_user_password.result
    db_host     = google_sql_database_instance.cloudsql_instance.private_ip_address
  }
  metadata_startup_script = file("startup-script.sh")
  service_account {
    email  = google_service_account.log_account.email
    scopes = ["cloud-platform"]
  }
  tags = ["webapp"]
}

#Create Compute Address for private service connection
resource "google_compute_global_address" "compute_address" {
  name          = "custom-compute-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.mainvpc.self_link
  #address      = "10.3.0.5"
}



#Adding to test for private service connection while terraform apply
resource "google_service_networking_connection" "vpc_connection_private" {
  network                 = google_compute_network.mainvpc.self_link
  service                 = "servicenetworking.googleapis.com"
  depends_on              = [google_compute_global_address.compute_address]
  reserved_peering_ranges = [google_compute_global_address.compute_address.name]
}


#Create Google SQL Database Instance
resource "google_sql_database_instance" "cloudsql_instance" {
  name             = var.sql_instance_name
  database_version = var.sql_database_version
  # project          = var.project_id
  # region           = var.region
  deletion_protection = var.sql_deletion_protection
  settings {
    tier                         = var.sql_tier
    availability_type            = var.sql_availability_type
    disk_type                    = var.sql_disk_type
    disk_size                    = var.sql_disk_size
  ip_configuration{
    ipv4_enabled                 = var.sql_ipv4_enabled
    private_network              = google_compute_network.mainvpc.self_link
    enable_private_path_for_google_cloud_services= true
  }
  }
}

#Creating Cloud SQL Database
resource "google_sql_database" "webapp_database" {
  name     = "webapp"
  instance = google_sql_database_instance.cloudsql_instance.name
}

#Generating random password as stated in the assignment
resource "random_password" "webapp_user_password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric           = true
}

#Create Cloud SQL User
resource "google_sql_user" "webapp_user" {
  name     = "webapp"
  instance = google_sql_database_instance.cloudsql_instance.name
  password = random_password.webapp_user_password.result
}

#data "google_dns_managed_zone" "cloud_dns_zone" {
 #name        = "rushikesh-deore-namecheap"
  #dns_name    = var.dns_name
  #description = "DNS zone for tld mapping .me"
  # project     = var.project_id
#}

resource "google_dns_record_set" "record_a" {
  name    = var.dns_name
  type    = "A"
  ttl     = 300
  #managed_zone = google_dns_managed_zone.cloud_dns_zone.name
  managed_zone="rushikesh-deore-namecheap"
  rrdatas = [
    google_compute_instance.webapp_instance.network_interface[0].access_config[0].nat_ip
  ]
}
resource "google_service_account" "log_account" {
  account_id   = "log-account"
  display_name = "Logging_Account"
}

resource "google_project_iam_binding" "writer_config_monitor" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:log-account@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "writer_metric_monitor" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:log-account@${var.project_id}.iam.gserviceaccount.com",
  ]
}
resource "google_pubsub_topic_iam_binding" "publisher" {
  topic =google_pubsub_topic.verify_email.id
  # project = var.project_id
  role   = "roles/pubsub.publisher"

  members = [
    # "serviceAccount:${google_service_account.gcf_sa.email}",
    # "serviceAccount:gcf-sa@${var.project_id}.iam.gserviceaccount.com",
    "serviceAccount:${google_service_account.log_account.email}",
  ]
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "verify_email_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-verify_email_bucket" # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "source_code" {
  type        = "zip"
  output_path = "/tmp/serverless.zip"
  source_dir  = "serverless/"
}

resource "google_storage_bucket_object" "code" {
  name   = "serverless.zip"
  bucket = google_storage_bucket.verify_email_bucket.name
  source = data.archive_file.source_code.output_path
}

resource "google_cloudfunctions2_function" "verify_email" {
  name        = "verify-email"
  location    = "us-east1"
  description = "Automated email verification service upon user creation"
  build_config {
    entry_point = "verifyEmail"
    runtime     = "nodejs18"
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.verify_email_bucket.name
        object = google_storage_bucket_object.code.name
      }
    }
  }
  service_config {
    max_instance_count = 1
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    # environment_variables = {
    #   SERVICE_CONFIG_TEST = "config_test"
    # }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.gcf_sa.email
  }
  event_trigger {
    trigger_region = "us-east1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
resource "google_pubsub_topic" "verify_email" {
  name                       = "verify_email"
  message_retention_duration = "604800s"
}

resource "google_service_account" "gcf_sa" {
  account_id   = "gcf-sa"
  display_name = "GCF Service Account"
}