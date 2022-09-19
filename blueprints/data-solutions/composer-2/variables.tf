/**
 * Copyright 2022 Google LLC
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

variable "composer_config" {
  description = "Composer environemnt configuration."
  type = object({
    environment_size = string
    image_version    = string
  })
  default = {
    environment_size = "ENVIRONMENT_SIZE_SMALL"
    image_version    = "composer-2-airflow-2"
  }
}

variable "groups" {
  description = "User groups."
  type        = map(string)
  default = {
    data-engineers = "gcp-data-engineers"
  }
}

variable "network_config" {
  description = "Shared VPC network configurations to use. If null networks will be created in projects with preconfigured values."
  type = object({
    host_project      = string
    network_self_link = string
    subnet_self_link  = string
    composer_secondary_ranges = object({
      pods     = string
      services = string
    })
  })
  default = null
}

variable "organization_domain" {
  description = "Organization domain."
  type        = string
}

variable "prefix" {
  description = "Unique prefix used for resource names. Not used for project if 'project_create' is null."
  type        = string
}

variable "project_create" {
  description = "Provide values if project creation is needed, uses existing project if null. Parent is in 'folders/nnn' or 'organizations/nnn' format."
  type = object({
    billing_account_id = string
    parent             = string
  })
  default = null
}

variable "project_id" {
  description = "Project id, references existing project if `project_create` is null."
  type        = string
}

variable "region" {
  description = "Region where instances will be deployed."
  type        = string
  default     = "europe-west1"
}

variable "service_encryption_keys" {
  description = "Cloud KMS keys to use to encrypt resources. Provide a key for each reagion in use."
  type        = map(string)
  default     = null
}
