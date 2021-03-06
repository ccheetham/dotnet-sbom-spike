#!/usr/bin/env bash

#set -x
set -euo pipefail

layers_dir="$1"
env_dir="$2/env"
plan_path="$3"

heading () {
  tput -T ansi setaf 2
  echo "---> $*"
  tput -T ansi sgr0
}

log () {
  tput -T ansi setaf 3
  echo "---- $*"
  tput -T ansi sgr0
}

syft_layer="$layers_dir/syft"
mkdir -p "$syft_layer"
ls "$syft_layer"
cat > "$layers_dir/syft.toml" << EOL
[types]
launch = true
cache = true
EOL


heading "Installing syft"

need_syft=true
syft_version=$(cat "$plan_path" | yj -t | jq -r '.entries[] | select(.name == "syft") | .metadata.version')
syft="$syft_layer/syft"
if [[ -x "$syft" ]]; then
  cached_version=$("$syft" --version | awk '{print $2}')
  if [[ $cached_version == $syft_version ]]; then
    need_syft=false
  else
    need_syft=true
    rm -rf $syft_layer/*
  fi
fi
if $need_syft; then
  log "downloading syft $syft_version"
  ls $syft_layer
  syft_url=https://github.com/anchore/syft/releases/download/v${syft_version}/syft_${syft_version}_linux_amd64.tar.gz
  wget $syft_url -q -O - | tar xfz - -C "$syft_layer"
else
  log "using syft $syft_version from cache"
fi
PATH+=:"$syft_layer"


heading "Determining Project Details"

project_file=$(ls *.[cf]sproj)
log "project file is $project_file"

project_name="${project_file%.*}"
log "project name is $project_name"

framework=$(grep '<TargetFramework>' "$project_file" | sed 's/<[^>]*>//g' | tr -d '[[:space:]]')
log "framework is $framework"


heading "Generating Project SBOM"

for dep_file in deps/*; do
  dep_name=$(basename $(basename deps/$dep_file) .deps.json | tr '.' '_' | tr '[[:upper:]]' '[[:lower:]]')
  log "generating SBOM for $dep_name"
  dep_layer="$layers_dir/$dep_name"
  mkdir -p "$dep_layer"
  cat > "$layers_dir/$dep_name.toml" << EOL
[types]
launch = true
EOL
syft packages "$dep_file" --output cyclonedx-json --file "${layers_dir}/$dep_name.sbom.cdx.json"
syft packages "$dep_file" --output syft-json --file "${layers_dir}/$dep_name.sbom.syft.json"
done
