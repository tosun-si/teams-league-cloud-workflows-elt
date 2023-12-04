#!/usr/bin/env bash

set -e
set -o pipefail
set -u

echo "############# Running the workflow... #######################"
echo "############# The config is #######################"

cat "$WORKFLOW_CONFIG_FILE_PATH"

escaped_json_config=$(jq -c . <"$WORKFLOW_CONFIG_FILE_PATH")

gcloud workflows run "$WORKFLOW_NAME" \
  --location "$LOCATION" \
  --data="$escaped_json_config"

echo "############# The workflow was run successfully #######################"
