# resource "google_compute_global_address" "lb_ip" {
#   name          = "lb-ip"
#   ip_version    = "IPV4"
#   purpose       = "GLOBAL"
# }
# reserve ip for load balancer
resource "google_compute_address" "loadbalancer" {
  name         = "loadbalancer"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
  region       = var.region
}

resource "google_compute_region_ssl_certificate" "ssl_certificate" {
  name        = "ssl-certificate"
  region      = var.region
  description = "Google-managed SSL certificate"
  project     = var.project_id
  certificate = file("rushikeshdeore_me.crt")
  private_key = file("privatekey.txt")

}

resource "google_compute_region_backend_service" "backend_service" {
  name                    = "backend-service"
  region                = var.region
  protocol                = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec             = 300
  port_name               = "http"
  enable_cdn              = false
  session_affinity      = "NONE"
  # security_policy         = var.security_policy
  # ssl_policy              = var.ssl_policy
  health_checks = [google_compute_region_health_check.https_health_check.id]
  backend {
    group                = "google_compute_region_instance_group_manager.webapp_instance_group_manager"
    balancing_mode       = "UTILIZATION"
    max_rate_per_instance = 1.0
  }
  # service_account_email          = google_service_account.gcf_sa.email

}

resource "google_compute_region_url_map" "url_map" {
  name        = "url-map"
  description = "a description"
  region          = var.region

  default_service = google_compute_region_backend_service.backend_service.id

  host_rule {
    hosts        = ["rushikeshdeore.me"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_region_backend_service.backend_service.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_region_backend_service.backend_service.id
    }
  }
}


resource "google_compute_region_target_https_proxy" "https_proxy" {
  name               = "https-proxy"
  region  = var.region
  url_map            = google_compute_region_url_map.url_map.self_link
  ssl_certificates   = [google_compute_region_ssl_certificate.ssl_certificate.self_link]
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  name                  = "forwarding-rule"
  ip_address            = google_compute_address.loadbalancer.address
  target                = google_compute_region_target_https_proxy.https_proxy.self_link
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  region     = var.region
  ip_protocol           = "TCP"
  network               = google_compute_network.mainvpc.id
  depends_on = [google_compute_subnetwork.subnet_1]
}

# output "load_balancer_ip" {
#   value = google_compute_global_address.lb_ip.address
# }
