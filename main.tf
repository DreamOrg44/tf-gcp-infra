provider "google" {
  #credentials = file("<path-to-your-service-account-key.json>")
  project     = "csye6225-ns-cloud"
  region      = "us-east1"
}

# Create VPC
resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create Subnets
resource "google_compute_subnetwork" "webapp" {
  name          = "webapp"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.my_vpc.name
}

resource "google_compute_subnetwork" "db" {
  name          = "db"
  ip_cidr_range = "10.0.1.0/24"
  region 	= "us-east1"
  network       = google_compute_network.my_vpc.name
}

# Add Route for webapp subnet
resource "google_compute_route" "webapp_route" {
  name         = "webapp-route"
  network      = google_compute_network.my_vpc.self_link
  dest_range   = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"

}

