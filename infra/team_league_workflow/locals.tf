locals {
  team_league_workflow_yaml_as_string        = file("${path.module}/resource/workflow/team_league_elt_gcs_file_schema.yaml")
  team_league_workflow_yaml_config_as_string = file("${path.module}/resource/workflow/config/workflow_config.json")
  team_league_workflow_yaml_config           = jsondecode(file("${path.module}/resource/workflow/config/workflow_config.json"))
  compute_and_insert_team_stats_data_query   = file("${path.module}/resource/workflow/config/query/compute_and_insert_team_stats_data.sql")
}