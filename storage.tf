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

resource "google_storage_bucket" "bucket" {
  for_each      = {for item in local.storageBuckets: item.name => item}
  name          = each.value.name
  location      = each.value.location
  storage_class = each.value.storageClass

  labels = {
    project   = var.project_id
    purpose   = each.value.purpose
  }

  dynamic "cors" {
    for_each = coalesce(each.value.corsRules, null) != null ? each.value.corsRules : []
    content {
      origin = cors.value.allowedOrigins
      method = coalesce(cors.value.allowedMethods, ["GET","HEAD"])
      response_header = coalesce(cors.value.exposeHeaders, ["*"])
      max_age_seconds = coalesce(cors.value.maxAgeSeconds, 5)
    }
  }

  versioning {
    enabled = each.value.versioningEnabled
  }

  # transition
  dynamic "lifecycle_rule" {
    for_each = coalesce(each.value.transitionRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = each.value.transitionRetainDays
      }
      action {
        type = "SetStorageClass"
        storage_class = each.value.transitionStorageClass
      }
    }
  }

  # versioning
  dynamic "lifecycle_rule" {
    for_each = coalesce(each.value.versioningRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = each.value.versioningRetainDays
        with_state = "ARCHIVED"
      }
      action {
        type = "Delete"
      }
    }
  }

  # lock
  dynamic "retention_policy" {
    for_each = coalesce(each.value.lockRetainDays, null) != null ? [1] : []
    content {
      is_locked           = true
      retention_period    = 60 * 60 * 24 * each.value.lockRetainDays
    }
  }

  # autoDeletion
  dynamic "lifecycle_rule" {
    for_each = coalesce(each.value.autoDeletionRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = each.value.autoDeletionRetainDays
        with_state = "ANY"
      }
      action {
        type = "Delete"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
