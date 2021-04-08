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

variable "project_id" {
  type        = string
}

# TODO: Not all attributes have been implemented
variable "storage_buckets" {
  type = list(object({
    name = string
    purpose = optional(string)
    location = string
    storageClass = string
    corsRules = optional(list(object({
      allowedOrigins = list(string)
      allowedMethods = optional(list(string))
      exposeHeaders = optional(list(string))
      maxAgeSeconds = optional(number)
    })))
    cdnDomain = optional(string)
    versioningEnabled = optional(bool)
    versioningRetainDays = optional(number)
    lockRetainDays = optional(number)
    transitionRetainDays = optional(number)
    transitionStorageClass = optional(string)
    autoDeletionRetainDays = optional(number)
    replicationBucket = optional(string)
    backupRetainDays = optional(number)
    backupLocation = optional(string)
    backupLock = optional(bool)
    members = optional(list(object({
      id = string
      roles = optional(list(string))
    })))
  }))
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}
