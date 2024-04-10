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
variable "compute_instance_template" {
  description = "The compute engine instanc asked to be created"
  type        = string
}

variable "zone" {
  description = "The compute engine instanc asked to be created"
  type        = string
}

variable "sql_instance_name" {
  description = "Name of the CloudSQL instance"
  type        = string
}

variable "sql_database_version" {
  description = "Database version for CloudSQL instance"
  type        = string
}

variable "sql_deletion_protection" {
  description = "Specifies whether deletion protection is enabled for the Cloud SQL instance."
  type        = string
}

variable "sql_availability_type" { 
  description = "Sets the availability type for the Cloud SQL instance (e.g., regional)."
  type        = string
}

variable "sql_disk_type" {
  description = "Defines the disk type for the Cloud SQL instance "
  type        = string
}

variable "sql_disk_size" { 
  description = "Specifies the size of the disk for the Cloud SQL instance"
  type        = string
}

variable "sql_ipv4_enabled" {
  description = "Indicates whether IPv4 is enabled for the Cloud SQL instance."
  type        = string
}

variable "sql_private_network" { 
  description = "Specifies the custom VPC for the Cloud SQL instance."
  type        = string
}

variable "sql_tier" {
  description = "Machine tier for Cloud SQL instance."
  type= string
}
variable "dns_name" {
  description = "Name of the dns server."
  type= string
}
variable "cloudsql_database_dialect" {
  description="database dialect"
  type=string
}
variable "mailgun_api_key"{
  description="api key for mailgun"
  type=string
}
variable "mailgun_domain" {
  description="domain for mailgun"
  type=string
}
variable "gcf_connector_name" {
  description="gcf connector"
  type=string
}
variable "gcf_connector_ip_cidr_range" {
  description="gcf connector ip range"
  type=string
}
variable "ip_cidr_range_proxy" {
  description="Proxy only ip range"
  type=string
}
variable "purpose" {
  description="Crypto keys purpose"
  type=string
}
