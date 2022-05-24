#!/usr/bin/env bash

#set -x
set -eo pipefail

source $(dirname $0)/../etc/profile.sh

usage () {
  cat << EOL
`bold USAGE`
    `code $prog` `under syftjson`

`bold DESCRIPTION`
    Show the dependencies described in a SYFT JSON file.
    The "pack" is done using the buildpack in this spike.

`bold WHERE`
    `code syftjson`
            path to a file containing SYFT JSON

`bold OPTIONS`
    `code -h`      print this message
EOL
}

while getopts ":h" opt ; do
  case $opt in
    h)
      usage
      exit
      ;;
    \?)
      die "invalid option -$OPTARG; run with -h for help"
      ;;
    :)
      die "option -$OPTARG requires an argument; run with -h for help" 2>&1
      ;;
  esac
done
shift $(($OPTIND-1))

if [[ $# == 0 ]]; then
  die "path to SYFT JSON not specified; run with -h for help"
fi

syftjson=$1
shift

if [[ $# > 0 ]]; then
  die "too many args; run with -h for help"
fi

[[ -f $syftjson ]] || die "path not found: $syftjson"

cat $syftjson | jq '.artifacts[] | .name + ":" + .version'
