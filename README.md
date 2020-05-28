# BigQuery Dataset module

This module allows you to create opinionated Google Cloud Platform BigQuery datasets. A Dataset consists of the dataset itself, tables, and views.
This module descends from Google Cloud's official BigQuery module, but has been altered to remove unnecessary functionality and add the ability to provision views and dataset-level permissions. 
See the official GCP BigQuery module [here](https://github.com/terraform-google-modules/terraform-google-bigquery). 

## Usage

Basic usage of this module is as follows:

```hcl
module "test_dataset" {
  source     = "./dataset"
  dataset_id = "<NAME OF DATASET>"

  dataset_roles = [
    {
      role           = "<ROLE TYPE>"
      special_group  = "<SPECIAL GROUP>"
      group_by_email = "<EMAIL GROUP>"
      user_by_email  = "<USER EMAIL>"
    }
  ]

  tables = [
    {
      table_id    = "<TABLE NAME>"
      schema      = "<PATH TO JSON SCHEMA FILE>"
      time_partitioning = {
        type                     = "DAY",
        field                    = null,
        require_partition_filter = false,
        expiration_ms            = null,
      }
      deduplication_view = {
        create       = <BOOLEAN, WHETHER TO CREATE DEDUP VIEW>
        partition_by = "<COLUMN TO PARTITION BY>"
        order_by     = "<COLUMN TO ORDER BY>"
        ascending    = <BOOLEAN>
      }
    }
  ]

  views = [
    {
      name           = "<NAME OF VIEW>"
      use_legacy_sql = <BOOLEAN>
      query          = "<PATH TO TEMPLATED SQL FILE>"
    }
  ]

  providers = {
    google = google-beta.warehouse
  }
}
```

### Variable `tables` detailed description

The `tables` variable should be provided as a list of object with the following keys:
```hcl
{
  table_id = "some_id"                        # Unique table id (will be used as ID and Freandly name for the table).
  schema = "path/to/schema.json"              # Path to the schema json file.
  time_partitioning = {                       # Set it to `null` to omit partitioning configuration for the table.
        type                     = "DAY",     # The only type supported is DAY, which will generate one partition per day based on data loading time.
        field                    = null,      # The field used to determine how to create a time-based partition. If time-based partitioning is enabled without this value, the table is partitioned based on the load time. Set it to `null` to omit configuration.
        require_partition_filter = false,     # If set to true, queries over this table require a partition filter that can be used for partition elimination to be specified. Set it to `null` to omit configuration.
        expiration_ms            = null,      # Number of milliseconds for which to keep the storage for a partition.
      },
  deduplication_view = {                      # Set create to `false` and the other parameters to null if no de-dup view needs to be provisioned.
        create       = true                   # Whether to create a de-duplication view of the table based on a partitioning column & ordering column. 
        partition_by = "id"                   # Column to partition by
        order_by     = "inserted_at"          # Column to order by
        ascending    = false                  # Order ascending or descending
  }
}
```

## Features
This module provisions a dataset and a list of tables with associated JSON schemas.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                           | Description                                                                                  |    Type     | Default  | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------- | :---------: | :------: | :------: |
| dataset\_id                    | Unique ID for the dataset being provisioned.                                                 |   string    |   n/a    |   yes    |
| dataset\_labels                | Key value pairs in a map for dataset labels                                                  | map(string) |   n/a    |   yes    |
| dataset\_name                  | Friendly name for the dataset being provisioned.                                             |   string    |   n/a    |   yes    |
| default\_table\_expiration\_ms | TTL of tables using the dataset in MS                                                        |   string    | `"null"` |    no    |
| description                    | Dataset description.                                                                         |   string    |   n/a    |   yes    |
| location                       | The regional location for the dataset only US and EU are allowed in module                   |   string    |  `"US"`  |    no    |
| project\_id                    | Project where the dataset and table are created                                              |   string    |   n/a    |   yes    |
| tables                         | A list of objects which include table_id, schema, time_partitioning, and deduplication_view. |   object    | `<list>` |    no    |
| views                          | A list of objects which include name, use_legacy_sql, and query.                             |   object    | `<list>` |    no    |
| authorized_views               | A list of objects which include project_id, dataset_id, table_id.                            |   object    | `<list>` |    no    |
| dataset_roles                  | A list of objects which include role, special_group, group_by_email, and user_by_email.      |   object    | `<list>` |    no    |

## Which project will my dataset live in?

This module doesn't have a variable for project id, rather it infers the project from the provider used to make the module. To ensure the dataset is created in the right project, simply pass a provider to the module explicitly:

```hcl
  providers = {
    google = google-beta.warehouse
  }
```

## Provisioning stand-alone views

The `views` variable has a `query` parameter that is a path to a templated SQL file for the view definition. BigQuery views must have the full resource definitions of the tables they reference: `project_id.dataset_id.table_id`

Because of this, all SQL files that are used to generate views need to include a templated `project` variable. This variable will automatically be filled in by the project of the dataset. 

Additionally, all resources **must** have single-quotes wrapped around them. 

An example SQL file is below:

```SQL
SELECT *
FROM `${project}.dataset.table`
```
