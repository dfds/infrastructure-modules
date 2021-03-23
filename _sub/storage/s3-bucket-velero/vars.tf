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
