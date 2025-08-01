/**
 * Copyright 2025 Google LLC
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

variable "iam" {
  description = "IAM bindings in {SECRET => {ROLE => [MEMBERS]}} format."
  type        = map(map(list(string)))
  default     = {}
}

variable "labels" {
  description = "Optional labels for each secret."
  type        = map(map(string))
  default     = {}
}

variable "project_id" {
  description = "Project id where the keyring will be created."
  type        = string
}

variable "project_number" {
  description = "Project number of var.project_id. Set this to avoid permadiffs when creating tag bindings."
  type        = string
  default     = null
}

variable "secrets" {
  description = "Map of secrets to manage, their optional expire time, version destroy ttl, locations and KMS keys in {LOCATION => KEY} format. {GLOBAL => KEY} format enables CMEK for automatic managed secrets. If locations is null, automatic management will be set."
  type = map(object({
    expire_time         = optional(string)
    locations           = optional(list(string))
    keys                = optional(map(string))
    tag_bindings        = optional(map(string))
    version_destroy_ttl = optional(string)
  }))
  default = {}
}

variable "versions" {
  description = "Optional versions to manage for each secret. Version names are only used internally to track individual versions."
  type = map(map(object({
    enabled = bool
    data    = string
  })))
  default = {}
}
