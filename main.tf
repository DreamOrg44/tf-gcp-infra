provider "google" {
  # credentials = file("/Users/rushikeshdeore/gCloudCLI/devProjectPackerKey/LastAssignment/csye-6225-ns-cloud-dev-1a56c2eac7b4.json")
  project = var.project_id
  region  = var.region
}

# Create VPC
resource "google_compute_network" "mainvpc" {
  name                            = var.vpc_name
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

# Create Subnets
resource "google_compute_subnetwork" "subnet_1" {
  name                     = var.subnetwork_name_1
  ip_cidr_range            = var.subnetwork_ip_cidr_range_1
  region                   = var.region
  network                  = google_compute_network.mainvpc.name
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet_2" {
  name                     = var.subnetwork_name_2
  ip_cidr_range            = var.subnetwork_ip_cidr_range_2
  region                   = var.region
  network                  = google_compute_network.mainvpc.name
  private_ip_google_access = true
}

# Add Route for webapp subnet
resource "google_compute_route" "subnet_route" {
  name             = var.route_name
  network          = google_compute_network.mainvpc.self_link
  dest_range       = var.dest_range
  next_hop_gateway = var.next_hop_gateway

}


# Create Firewall Rule
resource "google_compute_firewall" "firewall" {
  name    = var.firewall_name
  network = google_compute_network.mainvpc.id

  allow {
    protocol = var.firewall_protocol
    ports    = [var.application_port,22]
  }
  #changes here
  # source_ranges = [google_compute_subnetwork.subnet_3.ip_cidr_range]
  source_ranges = ["0.0.0.0/0"]

  # source_service_accounts = [google_service_account.instance_template_account.email] # Specify the service account email(s) you want to allow
  target_tags   = ["webapp"]
}

# resource "google_compute_firewall" "no_access_ssh" {
#   name    = "no-access-ssh"
#   network = google_compute_network.mainvpc.id

#  deny {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#  source_ranges = ["0.0.0.0/0"]
#  }

resource "google_compute_firewall" "health_check_firewall" {
  name          = "health-check-firewall"
  network       = google_compute_network.mainvpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  # priority      = var.priority + 2
  allow {
    protocol = var.firewall_protocol
    ports    = [var.application_port,22]
    # ports    = ["443"]
  }
}
#Never Delete
#changes here

#Create Google Compute Address For Compute Instance Access
# resource "google_compute_address" "internal_ip" {
#   name   = "internal-ip"
#   region = var.region
# }


# Create Compute Engine Instance
# resource "google_compute_instance" "webapp_instance" {
#   name         = var.compute_instance
#   machine_type = "e2-standard-2"
#   zone= var.zone
#   depends_on=[google_compute_network.mainvpc, google_service_account.log_account]

#   boot_disk {
#     initialize_params {
#       image = var.custom_image
#       size  = 100
#       type  = "pd-balanced"
#     }
#   }

#   network_interface {
#     subnetwork = google_compute_subnetwork.subnet_1.self_link
# 	access_config {
#       	# nat_ip = google_compute_address.internal_ip.address
#     	}
#   }
#    metadata = {
#     db_name     = google_sql_database.webapp_database.name
#     db_user     = google_sql_user.webapp_user.name
#     db_password = random_password.webapp_user_password.result
#     db_host     = google_sql_database_instance.cloudsql_instance.private_ip_address
#   }
#   metadata_startup_script = file("startup-script.sh")
#   service_account {
#     email  = google_service_account.log_account.email
#     scopes = ["cloud-platform"]
#   }
#   tags = ["webapp"]
# }
#changes here
resource "google_compute_region_instance_template" "webapp_instance_template" {
  name_prefix  = var.compute_instance_template
  machine_type = "e2-standard-2"
  region       = var.region

  disk {
    source_image = var.custom_image
    disk_size_gb = 100
    type         = "pd-balanced"
    boot         = true
    disk_encryption_key {
      kms_key_self_link=google_kms_crypto_key.vm_crypto_key.id
    }
  }

  network_interface {
    network    = google_compute_network.mainvpc.self_link
    subnetwork = google_compute_subnetwork.subnet_1.self_link
    access_config {
      network_tier = "STANDARD"
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
    email  = google_service_account.instance_template_account.email
    scopes = ["cloud-platform"]
  }
  lifecycle {
    create_before_destroy = true
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

# resource "google_project_iam_binding" "kms_binding" {
#   project = var.project_id

#   role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#   members = [
#       "serviceAccount:service-1050850969947@gs-project-accounts.iam.gserviceaccount.com",
#   ]
# }

#Create Google SQL Database Instance
resource "google_sql_database_instance" "cloudsql_instance" {
  name             = var.sql_instance_name
  database_version = var.sql_database_version
  # project          = var.project_id
  # region           = var.region
  deletion_protection = var.sql_deletion_protection
  encryption_key_name = google_kms_crypto_key.cloudsql_crypto_key.id
  settings {
    tier              = var.sql_tier
    availability_type = var.sql_availability_type
    disk_type         = var.sql_disk_type
    disk_size         = var.sql_disk_size
    ip_configuration {
      ipv4_enabled                                  = var.sql_ipv4_enabled
      private_network                               = google_compute_network.mainvpc.self_link
      enable_private_path_for_google_cloud_services = true
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
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
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
  name = var.dns_name
  type = "A"
  ttl  = 300
  #managed_zone = google_dns_managed_zone.cloud_dns_zone.name
  managed_zone = "rushikesh-deore-namecheap"
  rrdatas = [
    google_compute_forwarding_rule.forwarding_rule.ip_address
    #google_compute_region_instance_template.webapp_instance_template.network_interface[0].access_config[0].nat_ip
    #changes here
  ]
}
# resource "google_service_account" "log_account" {
#   account_id   = "log-account"
#   display_name = "Logging_Account"
# }


resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "verify_email_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-verify_email_bucket" # Every bucket name must be globally unique
  location                    = var.region
  uniform_bucket_level_access = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_crypto_key.id
  }
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

resource "google_vpc_access_connector" "gcf_connector" {
  name          = var.gcf_connector_name
  region        = var.region
  network       = google_compute_network.mainvpc.self_link
  ip_cidr_range = var.gcf_connector_ip_cidr_range
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
    vpc_connector      = google_vpc_access_connector.gcf_connector.self_link
    environment_variables = {
      DB_HOST         = google_sql_database_instance.cloudsql_instance.private_ip_address
      DB_NAME         = google_sql_database.webapp_database.name
      DB_DIALECT      = var.cloudsql_database_dialect
      DB_USER         = google_sql_user.webapp_user.name
      DB_PASSWORD     = random_password.webapp_user_password.result
      MAILGUN_API_KEY = var.mailgun_api_key
      MAILGUN_DOMAIN  = var.mailgun_domain
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.gcf_sa.email
    #checkHere
      # service_account_email          = google_service_account.instance_template_account.email

  }
  event_trigger {
    trigger_region = "us-east1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
  depends_on = [google_storage_bucket_object.code, google_vpc_access_connector.gcf_connector, google_pubsub_topic.verify_email]
}
#changes here
resource "google_pubsub_topic" "verify_email" {
  name                       = "verify_email"
  message_retention_duration = "604800s"
}



resource "google_compute_region_health_check" "https_health_check" {
  name        = "https-health-check"
  description = "Health check via https"

  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10
  region              = var.region
  http_health_check {
    port = var.application_port
    # port_specification = "USE_NAMED_PORT"
    # host               = google_compute_instance_template.webapp_instance_template.network_interface[0].network_ip
    request_path = "/healthz"
    # proxy_header       = "NONE"
    # response           = "I AM RUNNING HEALTHY"
  }
}

resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = "webapp-autoscaler"
  region = var.region
  #target            = google_compute_region_instance_group_manager.webapp_instance_group_manager.id
  target = google_compute_region_instance_group_manager.webapp_instance_group_manager.id

  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    cooldown_period = 60
    cpu_utilization {
      target = 0.05
    }
  }
  depends_on = [google_compute_region_instance_group_manager.webapp_instance_group_manager]
}
resource "google_compute_region_instance_group_manager" "webapp_instance_group_manager" {
  name               = "webapp-instance-group-manager"
  base_instance_name = "webapp-instance"
  # target_size        = 1
  region             = var.region
  distribution_policy_zones = [var.zone]
  version {
    instance_template = google_compute_region_instance_template.webapp_instance_template.self_link
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.https_health_check.id
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 3000
  }
  depends_on = [google_compute_region_instance_template.webapp_instance_template]
  # target_pools = [google_compute_target_pool.webapp_target_pool.self_link]
  # target_tags  = ["webapp"]
}

# resource "google_compute_target_pool" "webapp_target_pool" {
#   name          = "webapp-target-pool"
#   region        = var.region
#   health_checks = [google_compute_region_health_check.https_health_check.id]
# }

resource "google_compute_subnetwork" "subnet_3" {
  name          = "proxy-only-subnet"
  ip_cidr_range = var.ip_cidr_range_proxy
  network       = google_compute_network.mainvpc.self_link
  purpose       = "REGIONAL_MANAGED_PROXY"
  region        = var.region
  role          ="ACTIVE"
  }



  resource "google_secret_manager_secret" "db_password" {
  secret_id = "db_password"
  labels = {
    label = "password"
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.webapp_user_password.result
}


resource "google_secret_manager_secret" "db_host" {
  secret_id = "db_host"
  labels = {
    label = "host"
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_host" {
  secret      = google_secret_manager_secret.db_host.id
  secret_data = google_sql_database_instance.cloudsql_instance.private_ip_address
  depends_on  = [google_sql_database_instance.cloudsql_instance]
}


resource "google_secret_manager_secret" "key_ring" {
  secret_id = "key_ring"
  labels = {
    label = "key_ring"
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "key_ring" {
  secret      = google_secret_manager_secret.key_ring.id
  secret_data = google_kms_key_ring.my_key_ring.name
  depends_on  = [google_kms_key_ring.my_key_ring]
}