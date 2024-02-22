variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
}

variable "vpc_name" {
  description = "The name of the Virtual Private Cloud (VPC)"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Boolean flag to indicate whether subnetworks should be auto-created"
  type        = bool
}

variable "routing_mode" {
  description = "The routing mode for the VPC (e.g., 'REGIONAL')"
  type        = string
}

variable "subnetwork_name_1" {
  description = "The name of the first subnetwork"
  type        = string
}

variable "subnetwork_ip_cidr_range_1" {
  description = "The IP CIDR range for the first subnetwork"
  type        = string
}

variable "subnetwork_ip_cidr_range_2" {
  description = "The IP CIDR range for the first subnetwork"
  type        = string
}

variable "subnetwork_network" {
  description = "The name of the VPC to which the subnetworks belong"
  type        = string
}

variable "subnetwork_name_2" {
  description = "The name of the second subnetwork"
  type        = string
}

variable "route_name" {
  description = "The name of the route"
  type        = string
}

# variable "compute_route_network" {
#   description = "The name of the network to associate with the route"
#   type        = string
# }

variable "dest_range" {
  description = "The destination IP range for the route"
  type        = string
}

variable "next_hop_gateway" {
  description = "The next hop gateway for the route"
  type        = string
}

variable "custom_image" {
  description = "The image created through packer build"
  type        = string
}

variable "application_port" {
  description = "The port application listens to"
  type        = string
}

variable "firewall_name" {
  description = "The name of the firewall being created"
  type        = string
}

variable "firewall_protocol" {
  description = "The protocol new firewall will follow"
  type        = string
}

variable "compute_instance" {
  description = "The compute engine instanc asked to be created"
  type        = string
}

variable "zone" {
  description = "The compute engine instanc asked to be created"
  type        = string
}
