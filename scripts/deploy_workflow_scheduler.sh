#!/usr/bin/env bash

set -e
set -o pipefail
set -u

echo "############# Deploying the scheduler for the workflow... #######################"
echo "############# The config is #######################"

cat "$WORKFLOW_CONFIG_FILE_PATH"

escaped_json_config=$(jq -R -s '. | gsub("[\\n\\t]"; "")' <"$WORKFLOW_CONFIG_FILE_PATH")

gcloud scheduler jobs create http "$WORKFLOW_SCHEDULER_NAME" \
  --schedule="$WORKFLOW_SCHEDULER_INTERVAL" \
  --location "$LOCATION" \
  --uri="$WORKFLOW_URI" \
  --message-body="{\"argument\": ${escaped_json_config} }" \
  --time-zone="$WORKFLOW_SCHEDULER_TIME_ZONE" \
  --oauth-service-account-email="$WORKFLOW_SCHEDULER_SA"

echo "############# The scheduler was deployed successfully... #######################"
