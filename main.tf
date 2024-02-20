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
 #delete_default_routes_on_create = true
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

