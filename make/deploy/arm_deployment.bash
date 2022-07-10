#!/usr/bin/env bash

# REQ: Deploys the bicep project. <>

set +o braceexpand
set -o errexit
set -o noclobber
set -o nounset
set -o noglob
set -o pipefail

if [[ $LVL == 'debug' ]]
then
  set -o xtrace
fi

realpath="$(realpath "$0")"
dirname="$(dirname "$realpath")"
cd "$dirname/.."

source lib/options.bash

function main {
  parse_options "$@"

  make_resource_group
  make_deployment

  user_id=$(get_signed_in_user_id)

  service_principal_id=$(get_service_principal_id)

  create_resource_group
  create_deployment
}

function get_signed_in_user_id {
  az ad signed-in-user show --query id -o tsv --only-show-errors
}

function get_service_principal_id {
  service_principals=$(az ad sp list --display-name "$SERVICE_PRINCIPAL") 

  service_principals_size=$(jq -n "$service_principals|length")

  if [[ "$service_principals_size" -eq 1 ]]; then
    jq -nr "$service_principals[0].id"
  else
    exit 1
  fi
}

function create_deployment {
  az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file 'bicep/transcraft.bicep' \
    --parameters \
      user="$user_id" \
      servicePrincipal="$service_principal_id" \
      publicKey="$(cat "$SSH_PUBLIC_KEY")" \
      privateKey="$(cat "$SSH_PRIVATE_KEY")"
}

main "$@"
