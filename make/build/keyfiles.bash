#!/usr/bin/env bash

# REQ: Creates an SSH key pair. <skr 2022-07>

set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail

if [[ $LOG == 'debug' ]]
then
  set -o xtrace
fi

realpath="$(realpath "$0")"
dirname="$(dirname "$realpath")"
cd "$dirname/.."

source _lib/options.bash
source _lib/models/key_pair.bash

function main {
  parse_options "$@"

  make_key_pair

  generate_key_pair
}

main "$@"
