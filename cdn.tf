/**
 * Copyright 2020 Taito United
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
  count         = length(local.cdnStorageBuckets)

  name          = "${local.cdnStorageBuckets[count.index].name}-cdn"
  description   = "Backend bucket for serving static content through CDN"
  bucket_name   = local.cdnStorageBuckets[count.index].name
  enable_cdn    = true
  project       = data.google_project.project.project_id
}

resource "google_compute_url_map" "cdn_url_map" {
  count           = length(local.cdnStorageBuckets)

  name            = "${local.cdnStorageBuckets[count.index].name}-cdn-url-map"
  description     = "CDN URL map to cdn_backend_bucket"
  default_service = google_compute_backend_bucket.cdn_backend_bucket[count.index].self_link
  project         = data.google_project.project.project_id

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
  count           = length(local.cdnStorageBuckets)

  provider        = google-beta
  project         = data.google_project.project.project_id
  name            = "${local.cdnStorageBuckets[count.index].name}-cdn-certificate"

  managed {
    domains = [local.cdnStorageBuckets[count.index].cdnDomain]
  }
}

resource "google_compute_target_https_proxy" "cdn_https_proxy" {
  count            = length(local.cdnStorageBuckets)
  name             = "${local.cdnStorageBuckets[count.index].name}-cdn-https-proxy"
  url_map          = google_compute_url_map.cdn_url_map[count.index].self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_certificate[count.index].self_link]
  project          = data.google_project.project.project_id
}

resource "google_compute_global_address" "cdn_public_address" {
  count        = length(local.cdnStorageBuckets)
  name         = "${local.cdnStorageBuckets[count.index].name}-cdn-public-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
  project      = data.google_project.project.project_id
}

resource "google_compute_global_forwarding_rule" "cdn_global_forwarding_rule" {
  count      = length(local.cdnStorageBuckets)
  name       = "${local.cdnStorageBuckets[count.index].name}-cdn-forwarding-rule"
  target     = google_compute_target_https_proxy.cdn_https_proxy[count.index].self_link
  ip_address = google_compute_global_address.cdn_public_address[count.index].address
  port_range = "443"
  project    = data.google_project.project.project_id
}

resource "google_storage_bucket_iam_member" "cdn_all_users_viewers" {
  depends_on    = [google_storage_bucket.bucket]
  count         = length(local.cdnStorageBuckets)

  bucket        = local.cdnStorageBuckets[count.index].name
  role          = "roles/storage.legacyObjectReader"
  member        = "allUsers"
}
