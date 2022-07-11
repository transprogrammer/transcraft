#!/usr/bin/env bash

# REQ: Installs utilities with homebrew. <skr 2022-06 s:inprogress>

if [[ $LOG == 'debug' ]]
then
  set -o xtrace
fi

set -o braceexpand
set -o errexit
set -o noclobber
set -o nounset
set -o noglob
set -o pipefail

realpath="$(realpath "$0")"
dirname="$(dirname "$realpath")"
cd "$dirname"

function main {
  handle_brew
  run_brew_bundle
  
  make_local_dirs
  install_cloud-init
}

function handle_brew {
  if ! hash brew 2>/dev/null
  then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

run_brew_bundle() {
  local brewfile

  brewfile='
  brew "azure-cli"
  brew "bash"
  brew "dpkg"
  brew "gh"
  brew "gnu-tar"
  brew "openjdk"
  brew "yq"
  
  cask "multipass"
'
  brew bundle --file=- <<<$brewfile
}

function make_local_dirs {
  local local='/usr/local'
  declare -g src="$local/src" bin="$local/bin"

  sudo mkdir -p $src $bin
}

function install_cloud-init {
  r_path+='."rdf:RDF"'
  r_path+='."lp:ProductSeries"'
  r_path+='."lp:release"'
  r_path+=[0]

  r_path+='."lp:ProductRelease"'
  r_path+='."lp:specifiedAt"'
  r_path+='."@rdf:resource"'

  v_path+='."rdf:RDF"'
  v_path+='."lp:ProductRelease"'
  v_path+='."lp:version"'

  scheme='https'
  host='launchpad.net'
  name='cloud-init'
  release='trunk'

  resource=$(
    url="$scheme://$host/$name/$release/+rdf"
    curl -LSfs "$url" | xq -r "$r_path" 
  )

  version=$(
    url="$scheme://$host$resource"
    curl -LSfs "$url" | xq -r "$v_path"
  )

  url="$scheme://$host/$name/$release/$version/+download/$name-$version.tar.gz"
  curl -LSfs "$url" | sudo tar xz -C "$src"

  cd "$src/$name-$version"
  for command in 'build' 'develop'
  do
    sudo python3 setup.py "$command"
  done

  # CAVEAT: Hardcoded. <skr>
  source_file='../Cellar/python@3.9/3.9.13_1/Frameworks/Python.framework/Versions/3.9/bin/cloud-init'
  target_file='/opt/homebrew/bin/cloud-init'

  ! ln -s  "$source_file" "$target_file"
}

main
