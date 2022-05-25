#!/usr/bin/env bash

#set -x
set -eo pipefail

source $(dirname $0)/../etc/profile.sh

usage () {
  cat << EOL
`bold USAGE`
    `code $prog` -a `under app`
    `code $prog` -l

`bold DESCRIPTION`
    Run `code syft` in various ways on an app to list possible SBOM contents.
    Apps are located in the `code $(basename $apps_home)` dir; run with `code -l` for a listing.

    Before running `code syft`, `code dotnet publish -output publish` is run.
    Additional arguments to `code publish` can be specified in the file `code spike/publish` in the app project dir.

    The `code syft` command is found on your PATH.
    To specify a specific `code syft`, set the env var `code SYFT` tio its path.

`bold WHERE`
    `code app`    app in the `code $(basename $apps_home)` directory

`bold OPTIONS`
    `code -a`      app
    `code -l`      list available apps
    `code -h`      print this message

`bold EXAMPLES`
    Pack the webapi-net60 app:
            $ $prog -a webapi-net60
EOL
}

syft=${SYFT:-syft}
app=
do_list=false

while getopts ":a:lh" opt ; do
  case $opt in
    h)
      usage
      exit
      ;;
    a)
      app=$OPTARG
      ;;
    l)
      do_list=true
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

if [[ $# > 0 ]]; then
  die "too many args; run with -h for help"
fi

if [[ -z $app ]] && ! $do_list; then
  die "app not specified; run with -h for help"
fi

if [[ -n $app ]] && $do_list; then
  die "cannot specify both an app and list; run with -h for help"
fi

if $do_list; then
  ls -1 $apps_home
  exit
fi

app_dir=$apps_home/$app
[[ -d $app_dir ]] || die "app not found: $app"

msg "running dotnet publish"
publish_args=
[[ -f $app_dir/spike/publish ]] && publish_args=$(cat $app_dir/spike/publish)
eval run dotnet publish $app_dir $publish_args

(
  cd $app_dir
  msg "running syft on publish dir"
  run syft packages publish
  msg "running syft on app deps file"
  run syft packages publish/$app.deps.json
  dotnet_home=$(dirname $(command -v dotnet))
  runtime_cfg=publish/$app.runtimeconfig.json
  runtimes=$(cat $runtime_cfg | jq '.runtimeOptions.frameworks[].name' | tr -d '"')
  for runtime in $runtimes; do
    runtime_version=$(cat $runtime_cfg | jq '.runtimeOptions.frameworks[] | select(.name=="'$runtime'") | .version' | tr -d '"')
    msg "running syft on runtime $runtime:$runtime_version"
    runtime_deps=$dotnet_home/shared/$runtime/$runtime_version/$runtime.deps.json
    run syft packages $runtime_deps
  done
)
