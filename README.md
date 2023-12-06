# teams-league-cloud-workflows-elt

This project shows a real world use case with ELT pipeline using Cloud Storage, BigQuery and Cloud Workflows

## Deployment and run with gcloud commands

### Deploy the Workflows

```bash
gcloud workflows deploy team-league-elt-gcs-schema \
  --source=workflow/team_league_elt_gcs_file_schema.yaml \
  --location europe-west1 \
  --service-account sa-workflows-dev@gb-poc-373711.iam.gserviceaccount.com
```

### Run the Workflows

```bash
gcloud workflows run team-league-elt-gcs-schema \
  --location europe-west1 \
  --data='{"workflow_name":"team_league_workflow_elt","team_stats_raw_bq_create_disposition":"CREATE_NEVER","team_stats_raw_bq_write_disposition":"WRITE_APPEND","team_stats_raw_bq_source_format":"NEWLINE_DELIMITED_JSON","team_stats_raw_bq_schema_uri":"gs://mazlum_dev/workflows/team_league/schema/team_stats_raw_table_schema.json","dataset":"mazlum_test","team_stat_table":"team_stat","team_stat_raw_table":"team_stat_raw","team_stats_raw_files_hot_source_uri":"gs://mazlum_dev/workflows/team_league/elt/hot/*.json","team_stats_raw_files_cold_destination_uri":"gs://mazlum_dev/workflows/team_league/elt/cold/"}'
```

### Run the Workflows with Cloud Scheduler

#### Give the permissions to trigger the Workflow

To allow the principal that will run your Cloud Scheduler commands the ability to act as an Identity and Access Management
(IAM) service account, grant a role that allows the principal to impersonate the service account.

Grant your new service account the workflows.invoker role so that the account has permission to trigger your workflow:

```bash
gcloud projects add-iam-policy-binding gb-poc-373711 \
  --member serviceAccount:sa-workflows-dev@gb-poc-373711.iam.gserviceaccount.com \
  --role roles/workflows.invoker
```

#### Create the Cloud Scheduler job with a cron

```bash
gcloud scheduler jobs create http team-league-elt-gcs-schema-cron-job \
    --schedule="0 0 1 * *" \
    --location europe-west1 \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/gb-poc-373711/locations/europe-west1/workflows/team-league-elt-gcs-schema/executions" \
    --message-body="{\"argument\": \"{\\\"workflow_name\\\": \\\"team_league_workflow_elt\\\",\\\"team_stats_raw_bq_create_disposition\\\": \\\"CREATE_NEVER\\\",\\\"team_stats_raw_bq_write_disposition\\\": \\\"WRITE_APPEND\\\",\\\"team_stats_raw_bq_source_format\\\": \\\"NEWLINE_DELIMITED_JSON\\\",\\\"team_stats_raw_bq_schema_uri\\\": \\\"gs://mazlum_dev/workflows/team_league/schema/team_stats_raw_table_schema.json\\\",\\\"dataset\\\": \\\"mazlum_test\\\",\\\"team_stat_table\\\": \\\"team_stat\\\",\\\"team_stat_raw_table\\\": \\\"team_stat_raw\\\",\\\"team_stats_raw_files_hot_source_uri\\\": \\\"gs://mazlum_dev/workflows/team_league/elt/hot/*.json\\\",\\\"team_stats_raw_files_cold_destination_uri\\\": \\\"gs://mazlum_dev/workflows/team_league/elt/cold/\\\"}\"}" \
    --time-zone="Europe/Paris" \
    --oauth-service-account-email="sa-workflows-dev@gb-poc-373711.iam.gserviceaccount.com"
```

### Deployment and run with gcloud commands and Cloud Build

#### Deploy the Workflow

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-workflow.yaml \
    --substitutions _WORKFLOW_NAME="$WORKFLOW_NAME",_WORKFLOW_SOURCE="$WORKFLOW_SOURCE",_WORKFLOW_SA="$WORKFLOW_SA" \
    --verbosity="debug" .
```

#### Run the Workflow

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config run-workflow.yaml \
    --substitutions _WORKFLOW_CONFIG_FILE_PATH="$WORKFLOW_CONFIG_FILE_PATH",_WORKFLOW_NAME="$WORKFLOW_NAME" \
    --verbosity="debug" .
```

#### Deploy the Workflow with Cloud Scheduler

```bash
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-workflow-scheduler.yaml \
    --substitutions _WORKFLOW_CONFIG_FILE_PATH="$WORKFLOW_CONFIG_FILE_PATH",_WORKFLOW_URI="$WORKFLOW_URI",_WORKFLOW_SCHEDULER_NAME="$WORKFLOW_SCHEDULER_NAME",_WORKFLOW_SCHEDULER_INTERVAL="$WORKFLOW_SCHEDULER_INTERVAL",_WORKFLOW_SCHEDULER_TIME_ZONE="$WORKFLOW_SCHEDULER_TIME_ZONE",_WORKFLOW_SCHEDULER_SA="$WORKFLOW_SCHEDULER_SA" \
    --verbosity="debug" .
```

## Deployment and run with Cloud Build and Terraform

### Plan

```shell
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-workflow-scheduler-terraform-plan.yaml \
    --substitutions _TF_STATE_BUCKET=$TF_STATE_BUCKET,_TF_STATE_PREFIX=$TF_STATE_PREFIX,_WORKFLOW_NAME=$WORKFLOW_NAME,_WORKFLOW_SOURCE=$WORKFLOW_SOURCE,_WORKFLOW_URI=$WORKFLOW_URI,_WORKFLOW_SCHEDULER_SA=$WORKFLOW_SCHEDULER_SA,_WORKFLOW_SCHEDULER_NAME=$WORKFLOW_SCHEDULER_NAME,_WORKFLOW_SCHEDULER_INTERVAL=$WORKFLOW_SCHEDULER_INTERVAL,_WORKFLOW_SCHEDULER_TIME_ZONE=$WORKFLOW_SCHEDULER_TIME_ZONE,_WORKFLOW_SCHEDULER_SA=$WORKFLOW_SCHEDULER_SA,_GOOGLE_PROVIDER_VERSION=$GOOGLE_PROVIDER_VERSION \
    --verbosity="debug" .
```

### Apply

```shell
gcloud builds submit \
    --project=$PROJECT_ID \
    --region=$LOCATION \
    --config deploy-workflow-scheduler-terraform-apply.yaml \
    --substitutions _TF_STATE_BUCKET=$TF_STATE_BUCKET,_TF_STATE_PREFIX=$TF_STATE_PREFIX,_WORKFLOW_NAME=$WORKFLOW_NAME,_WORKFLOW_SOURCE=$WORKFLOW_SOURCE,_WORKFLOW_URI=$WORKFLOW_URI,_WORKFLOW_SCHEDULER_SA=$WORKFLOW_SCHEDULER_SA,_WORKFLOW_SCHEDULER_NAME=$WORKFLOW_SCHEDULER_NAME,_WORKFLOW_SCHEDULER_INTERVAL=$WORKFLOW_SCHEDULER_INTERVAL,_WORKFLOW_SCHEDULER_TIME_ZONE=$WORKFLOW_SCHEDULER_TIME_ZONE,_WORKFLOW_SCHEDULER_SA=$WORKFLOW_SCHEDULER_SA,_GOOGLE_PROVIDER_VERSION=$GOOGLE_PROVIDER_VERSION \
    --verbosity="debug" .
```