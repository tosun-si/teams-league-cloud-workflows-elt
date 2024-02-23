data "template_file" "raw_to_domain_query_template" {
  template = local.compute_and_insert_team_stats_data_query
  vars     = {
    project_id          = var.project_id
    dataset             = local.team_league_workflow_yaml_config["dataset"]
    team_stat_table     = local.team_league_workflow_yaml_config["team_stat_table"]
    team_stat_raw_table = local.team_league_workflow_yaml_config["team_stat_raw_table"]
  }
}

resource "google_cloud_scheduler_job" "workflow_elt_scheduler" {
  project          = var.project_id
  region           = var.location
  name             = var.workflow_scheduler_name
  description      = "Scheduler for team league workflow"
  schedule         = var.workflow_scheduler_interval
  time_zone        = var.workflow_scheduler_timezone
  attempt_deadline = "320s"

  http_target {
    body = base64encode(
      jsonencode({
        "argument" : local.team_league_workflow_yaml_config_as_string,
        "callLogLevel" : "CALL_LOG_LEVEL_UNSPECIFIED"
      }
      ))
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.location}/workflows/${var.workflow_name}/executions"

    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = var.workflow_scheduler_sa
    }
  }
}

resource "google_workflows_workflow" "workflow_elt_team_league" {
  depends_on = [
    data.template_file.raw_to_domain_query_template
  ]
  project         = var.project_id
  region          = var.location
  name            = var.workflow_name
  description     = "Workflow for team league ELT"
  service_account = var.workflow_sa
  source_contents = replace(local.team_league_workflow_yaml_as_string, "{{sql_query}}", data.template_file.raw_to_domain_query_template.rendered)
}
