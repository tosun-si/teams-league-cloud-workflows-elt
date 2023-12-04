module "cloud_workflow" {
  project = var.project_id
  source  = "terraform-google-modules/cloud-workflow/google"
  version = "~> 0.1"

  workflow_name         = "team-league-elt-gcs-schema"
  region                = "europe-west1"
  service_account_email = "sa-workflows-dev@gb-poc-373711.iam.gserviceaccount.com"
  workflow_trigger      = {
    cloud_scheduler = {
      name                  = "team-league-elt-gcs-schema-cron-job"
      cron                  = "0 0 1 * *"
      time_zone             = "Europe/Paris"
      deadline              = "320s"
      service_account_email = "sa-workflows-dev@gb-poc-373711.iam.gserviceaccount.com"
      argument              = local.team_league_workflow_yaml_config
    }
  }
  workflow_source = local.team_league_workflow_yaml_as_string
}

