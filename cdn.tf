/**
 * Copyright 2021 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

resource "google_compute_backend_bucket" "cdn_backend_bucket" {
  depends_on    = [google_storage_bucket.bucket]
  for_each      = {for item in local.cdnStorageBuckets: item.name => item}

  name          = "${each.value.name}-cdn"
  description   = "Backend bucket for serving static content through CDN"
  bucket_name   = each.value.name
  enable_cdn    = true
  project       = var.project_id
}

resource "google_compute_url_map" "cdn_url_map" {
  for_each        = {for item in local.cdnStorageBuckets: item.name => item}

  name            = "${each.value.name}-cdn-url-map"
  description     = "CDN URL map to cdn_backend_bucket"
  default_service = google_compute_backend_bucket.cdn_backend_bucket[each.key].self_link
  project         = var.project_id

  header_action {
    response_headers_to_remove = ["Server", "X-Powered-By"]
    response_headers_to_add {
      header_name = "Content-Security-Policy"
      header_value = "frame-ancestors 'none'"
      replace = false
    }
    response_headers_to_add {
      header_name = "X-Content-Type-Options"
      header_value = "nosniff"
      replace = true
    }
    response_headers_to_add {
      header_name = "Referrer-Policy"
      header_value = "strict-origin-when-cross-origin"
      replace = true
    }
  }
}

resource "google_compute_managed_ssl_certificate" "cdn_certificate" {
  for_each        = {for item in local.cdnStorageBuckets: item.name => item}

  provider        = google-beta
  project         = var.project_id
  name            = "${each.value.name}-cdn-certificate"

  managed {
    domains = [each.value.cdnDomain]
  }
}

resource "google_compute_target_https_proxy" "cdn_https_proxy" {
  for_each         = {for item in local.cdnStorageBuckets: item.name => item}
  name             = "${each.value.name}-cdn-https-proxy"
  url_map          = google_compute_url_map.cdn_url_map[each.key].self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_certificate[each.key].self_link]
  project          = var.project_id
}

resource "google_compute_global_address" "cdn_public_address" {
  for_each     = {for item in local.cdnStorageBuckets: item.name => item}
  name         = "${each.value.name}-cdn-public-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
  project      = var.project_id
}

resource "google_compute_global_forwarding_rule" "cdn_global_forwarding_rule" {
  for_each   = {for item in local.cdnStorageBuckets: item.name => item}
  name       = "${each.value.name}-cdn-forwarding-rule"
  target     = google_compute_target_https_proxy.cdn_https_proxy[each.key].self_link
  ip_address = google_compute_global_address.cdn_public_address[each.key].address
  port_range = "443"
  project    = var.project_id
}

resource "google_storage_bucket_iam_member" "cdn_all_users_viewers" {
  depends_on    = [google_storage_bucket.bucket]
  for_each      = {for item in local.cdnStorageBuckets: item.name => item}

  bucket        = each.value.name
  role          = "roles/storage.legacyObjectReader"
  member        = "allUsers"
}
