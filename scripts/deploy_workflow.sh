#!/usr/bin/env bash

set -e
set -o pipefail
set -u

echo "############# Deploying the workflow... #######################"

gcloud workflows deploy "$WORKFLOW_NAME" \
  --source="$WORKFLOW_SOURCE" \
  --location "$LOCATION" \
  --service-account "$WORKFLOW_SA"

echo "############# The workflow was deployed successfully #######################"
