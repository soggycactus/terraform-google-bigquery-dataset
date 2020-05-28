locals {
  tables = { for table in var.tables : table["table_id"] => table }
}

resource "google_bigquery_table" "tables" {
  for_each      = local.tables
  dataset_id    = google_bigquery_dataset.dataset.dataset_id
  friendly_name = each.key
  table_id      = each.key
  schema        = file(each.value["schema"])

  dynamic "time_partitioning" {
    for_each = each.value["time_partitioning"] != null ? [each.value["time_partitioning"]] : []
    content {
      type                     = time_partitioning.value["type"]
      expiration_ms            = time_partitioning.value["expiration_ms"]
      field                    = time_partitioning.value["field"]
      require_partition_filter = time_partitioning.value["require_partition_filter"]
    }
  }
}