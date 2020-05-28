variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
}

variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned."
  default     = null
}

variable "description" {
  description = "Dataset description."
  default     = null
}

variable "location" {
  description = "The regional location for the dataset only US and EU are allowed in module"
  default     = "US"
}

variable "default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS"
  default     = null
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels"
  type        = map(string)
  default     = null
}

variable "tables" {
  description = "A list of objects which include table_id, schema, time_partitioning, and whether to configure a deduplication view."
  default     = []
  type = list(object({
    table_id = string,
    schema   = string,
    time_partitioning = object({
      expiration_ms            = string,
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    deduplication_view = object({
      create       = bool
      partition_by = string
      order_by     = string
      ascending    = bool
    })
  }))
}

variable "views" {
  description = "A list of views to provision within this dataset."
  default     = []
  type = list(object({
    name           = string
    use_legacy_sql = bool
    query          = string
  }))
}

variable "authorized_views" {
  description = "A map of authorized views for the dataset"
  default     = []
  type = list(object({
    project_id = string
    dataset_id = string
    table_id   = string
  }))
}

variable "dataset_roles" {
  description = "A map of dataset-level roles including the role, special_group, group_by_email, and user_by_email"
  default     = []
  type = list(object({
    role           = string
    special_group  = string
    group_by_email = string
    user_by_email  = string
  }))
}