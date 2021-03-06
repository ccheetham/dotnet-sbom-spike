#!/usr/bin/env bash

set -eo pipefail

project_pattern='*.*proj'

if ! ls $project_pattern 2>/dev/null; then
  echo "no project file detected ($project_pattern)" >&2
  exit 1
fi

plan="$2"
syft_version=0.46.1

if [[ -f .syft-version ]]; then
  syft_version=$(cat .syft-version | tr -d '[:space:]')
fi

cat > "$plan" << EOL
provides = [{ name = "syft" }]
requires = [{ name = "syft", metadata = { version = "$syft_version" } }]
EOL
