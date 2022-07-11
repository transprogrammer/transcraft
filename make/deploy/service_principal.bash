#!/usr/bin/env bash

# REQ: Creates the environment service principal. <>

set +o braceexpand
set -o errexit
set -o noclobber
set -o nounset
set -o noglob
set -o pipefail

if [[ $LOG == 'debug' ]]
then
  set -o xtrace
fi

realpath="$(realpath "$0")"
dirname="$(dirname "$realpath")"
cd "$dirname/.."

source _lib/options.bash
source _lib/models/service_principal.bash

function main {
  parse_options "$@"

  make_service_principal
  create_service_principal
}

main "$@"
