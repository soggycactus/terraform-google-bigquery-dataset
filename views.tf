locals {
  dedup_views = { for view in var.tables : view["table_id"] => view if view["deduplication_view"]["create"] == true }
  views       = { for view in var.views : view["name"] => view }
}

resource "google_bigquery_table" "deduplication_views" {
  for_each   = local.dedup_views
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "${each.value["table_id"]}_view"

  view {
    use_legacy_sql = "false"
    query          = "SELECT * EXCEPT (ROW_NUMBER) FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY ${each.value["deduplication_view"]["partition_by"]} ORDER BY ${each.value["deduplication_view"]["order_by"]} ${each.value["deduplication_view"]["ascending"] == true ? "ASC" : "DESC"}) ROW_NUMBER FROM `${google_bigquery_dataset.dataset.project}.${google_bigquery_dataset.dataset.dataset_id}.${each.value["table_id"]}`) WHERE ROW_NUMBER = 1"
  }

  depends_on = [google_bigquery_table.tables]
}

resource "google_bigquery_table" "views" {
  for_each   = local.views
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = each.value["name"]

  view {
    use_legacy_sql = each.value["use_legacy_sql"]
    query          = templatefile(each.value["query"], { project = google_bigquery_dataset.dataset.project })
  }

  depends_on = [google_bigquery_table.tables]
}