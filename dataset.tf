resource "google_bigquery_dataset" "dataset" {
  dataset_id    = var.dataset_id
  friendly_name = var.dataset_name
  description   = var.description
  location      = var.location

  default_table_expiration_ms = var.default_table_expiration_ms
  labels                      = var.dataset_labels

  dynamic "access" {
    iterator = view
    for_each = var.authorized_views
    content {
      view {
        project_id = view.value["project_id"]
        dataset_id = view.value["dataset_id"]
        table_id   = view.value["table_id"]
      }
    }
  }

  dynamic "access" {
    iterator = role
    for_each = var.dataset_roles
    content {
      role           = role.value["role"]
      special_group  = role.value["special_group"]
      group_by_email = role.value["group_by_email"]
      user_by_email  = role.value["user_by_email"]
    }
  }
}