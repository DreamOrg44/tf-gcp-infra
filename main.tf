provider "google" {
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
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = var.subnetwork_name_2
  ip_cidr_range = var.subnetwork_ip_cidr_range_2
  region 	= var.region
  network       = google_compute_network.mainvpc.name
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

# Create Compute Engine Instance
resource "google_compute_instance" "webapp_instance" {
  name         = var.compute_instance
  machine_type = "n1-standard-1"
  zone= var.zone
  boot_disk {
    initialize_params {
      image = var.custom_image
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_1.self_link
    network_ip = google_compute_subnetwork.subnet_1.ip_cidr_range
	access_config {
      	// No specific configuration for now
    	}
  }

  tags = ["webapp"]
}
