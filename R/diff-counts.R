omop_diff_tables_row_count <- function(db, schema_left = "dbo", schema_right = "dbo2") {
  left <- omop_tables_row_count(db, schema = schema_left) |>
    rename(left_row_count = row_count)
  right <- omop_tables_row_count(db, schema = schema_right) |>
    rename(right_row_count = row_count)
  left |>
    full_join(right, by = "table") |>
    mutate(change = right_row_count - left_row_count)
}


omop_diff_plugins_row_count <- function(
    db,
    schema_public_left = "dbo",
    schema_private_left = "priv",
    schema_public_right = "dbo",
    schema_private_right = "priv") {
  left <- omop_plugin_row_count(
    db,
    schema_public = schema_public_left,
    schema_private = schema_private_left
  ) |>
    rename(left_row_count = row_count)
  right <- omop_plugin_row_count(
    db,
    schema_public = schema_public_right,
    schema_private = schema_private_right
  ) |>
    rename(right_row_count = row_count)
  left |>
    full_join(right, by = c("table", "plugin")) |>
    mutate(change = right_row_count - left_row_count)
}
