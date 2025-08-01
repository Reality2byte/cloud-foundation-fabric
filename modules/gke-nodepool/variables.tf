/**
 * Copyright 2024 Google LLC
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

variable "cluster_id" {
  description = "Cluster id. Optional, but providing cluster_id is recommended to prevent cluster misconfiguration in some of the edge cases."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Cluster name."
  type        = string
}

variable "gke_version" {
  description = "Kubernetes nodes version. Ignored if auto_upgrade is set in management_config."
  type        = string
  default     = null
}

variable "k8s_labels" {
  description = "Kubernetes labels applied to each node."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "labels" {
  description = "The resource labels to be applied each node (vm)."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "location" {
  description = "Cluster location."
  type        = string
}

variable "max_pods_per_node" {
  description = "Maximum number of pods per node."
  type        = number
  default     = null
}

variable "name" {
  description = "Optional nodepool name."
  type        = string
  default     = null
}

variable "network_config" {
  description = "Network configuration."
  type = object({
    enable_private_nodes = optional(bool)
    pod_range = optional(object({
      cidr   = optional(string)
      create = optional(bool, false)
      name   = optional(string)
    }), {})
    additional_node_network_configs = optional(list(object({
      network    = string
      subnetwork = string
    })), [])
    additional_pod_network_configs = optional(list(object({
      subnetwork          = string
      secondary_pod_range = string
      max_pods_per_node   = string
    })), [])
    total_egress_bandwidth_tier        = optional(string)
    pod_cidr_overprovisioning_disabled = optional(bool, false)
  })
  default = null
}

variable "node_config" {
  description = "Node-level configuration."
  type = object({
    boot_disk_kms_key   = optional(string)
    disk_size_gb        = optional(number)
    disk_type           = optional(string, "pd-balanced")
    ephemeral_ssd_count = optional(number)
    gcfs                = optional(bool, false)
    guest_accelerator = optional(object({
      count = number
      type  = string
      gpu_driver = optional(object({
        version                    = string
        partition_size             = optional(string)
        max_shared_clients_per_gpu = optional(number)
      }))
    }))
    local_nvme_ssd_count = optional(number)
    gvnic                = optional(bool, false)
    image_type           = optional(string)
    kubelet_config = optional(object({
      cpu_manager_policy                     = string
      cpu_cfs_quota                          = optional(bool)
      cpu_cfs_quota_period                   = optional(string)
      insecure_kubelet_readonly_port_enabled = optional(string)
      pod_pids_limit                         = optional(number)
      container_log_max_size                 = optional(string)
      container_log_max_files                = optional(number)
      image_gc_low_threshold_percent         = optional(number)
      image_gc_high_threshold_percent        = optional(number)
      image_minimum_gc_age                   = optional(string)
      image_maximum_gc_age                   = optional(string)
      allowed_unsafe_sysctls                 = optional(list(string), [])
    }))
    linux_node_config = optional(object({
      sysctls     = optional(map(string))
      cgroup_mode = optional(string)
    }))
    local_ssd_count       = optional(number)
    machine_type          = optional(string)
    metadata              = optional(map(string))
    min_cpu_platform      = optional(string)
    preemptible           = optional(bool)
    sandbox_config_gvisor = optional(bool)
    shielded_instance_config = optional(object({
      enable_integrity_monitoring = optional(bool)
      enable_secure_boot          = optional(bool)
    }))
    spot                          = optional(bool)
    workload_metadata_config_mode = optional(string)
  })
  default  = {}
  nullable = false
  validation {
    condition = (
      alltrue([
        for k, v in try(var.node_config.guest_accelerator[0].gpu_driver, {}) : contains([
          "GPU_DRIVER_VERSION_UNSPECIFIED", "INSTALLATION_DISABLED",
          "DEFAULT", "LATEST"
        ], v.version)
      ])
    )
    error_message = "Invalid GPU driver version."
  }
  validation {
    condition = contains(
      ["GCE_METADATA", "GKE_METADATA", "null"],
      coalesce(var.node_config.workload_metadata_config_mode, "null")
    )
    error_message = "node_config.workload_metadata_config_mode must be GCE_METADATA or GKE_METADATA."
  }
}

variable "node_count" {
  description = "Number of nodes per instance group. Initial value can only be changed by recreation, current is ignored when autoscaling is used."
  type = object({
    current = optional(number)
    initial = number
  })
  default = {
    initial = 1
  }
  nullable = false
}

variable "node_locations" {
  description = "Node locations."
  type        = list(string)
  default     = null
}

variable "nodepool_config" {
  description = "Nodepool-level configuration."
  type = object({
    autoscaling = optional(object({
      location_policy = optional(string)
      max_node_count  = optional(number)
      min_node_count  = optional(number)
      use_total_nodes = optional(bool, false)
    }))
    management = optional(object({
      auto_repair  = optional(bool)
      auto_upgrade = optional(bool)
    }))
    placement_policy = optional(object({
      type         = string
      policy_name  = optional(string)
      tpu_topology = optional(string)
    }))
    queued_provisioning = optional(bool, false)
    upgrade_settings = optional(object({
      max_surge       = number
      max_unavailable = number
      strategy        = optional(string)
      blue_green_settings = optional(object({
        node_pool_soak_duration = optional(string)
        standard_rollout_policy = optional(object({
          batch_percentage    = optional(number)
          batch_node_count    = optional(number)
          batch_soak_duration = optional(string)
        }))
      }))
    }))
  })
  default = null
}

variable "project_id" {
  description = "Cluster project id."
  type        = string
}

variable "reservation_affinity" {
  description = "Configuration of the desired reservation which instances could take capacity from."
  type = object({
    consume_reservation_type = string
    key                      = optional(string)
    values                   = optional(list(string))
  })
  default = null
}

variable "service_account" {
  description = "Nodepool service account. If this variable is set to null, the default GCE service account will be used. If set and email is null, a service account will be created. If scopes are null a default will be used."
  type = object({
    create       = optional(bool, false)
    email        = optional(string)
    oauth_scopes = optional(list(string))
    display_name = optional(string)
  })
  default  = {}
  nullable = false
}

variable "sole_tenant_nodegroup" {
  description = "Sole tenant node group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Network tags applied to nodes."
  type        = list(string)
  default     = null
}

variable "taints" {
  description = "Kubernetes taints applied to all nodes."
  type = map(object({
    value  = string
    effect = string
  }))
  nullable = false
  default  = {}
  validation {
    condition = alltrue([
      for k, v in var.taints :
      contains(["NO_SCHEDULE", "PREFER_NO_SCHEDULE", "NO_EXECUTE"], v.effect)
    ])
    error_message = "Invalid taint effect."
  }
}
