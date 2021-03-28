variable bucket_name {
  type        = string
  default     = "velero-storage"
  description = ""
}

variable kiam_server_role_arn {
  type        = string
  default     = ""
  description = ""
}

variable versioning {
  type        = bool
  default     = false
  description = ""
}

variable "velero_iam_role_name" {
  type = string
  default = "VeleroBackupRole"
  description = ""
}

variable force_bucket_destroy {
  type        = bool
  default     = true
  description = "Destroy bucket without error"
}
