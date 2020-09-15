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

# TODO: Not all attributes have been implemented
variable "storage_buckets" {
  type = list(object({
    name = string
    purpose = string
    location = string
    storageClass = string
    cors = list(object({
      origin = string
    }))
    cdnDomain = string
    cloudbuildDeployEnabled = bool
    versioningEnabled = bool
    versioningRetainDays = number
    lockRetainDays = number
    transitionRetainDays = number
    transitionStorageClass = string
    autoDeletionRetainDays = number
    replicationBucket = string
    backupRetainDays = number
    backupLocation = string
    backupLock = bool
    admins = list(object({
      id = string
    }))
    objectAdmins = list(object({
      id = string
    }))
    objectViewers = list(object({
      id = string
    }))
  }))
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}
