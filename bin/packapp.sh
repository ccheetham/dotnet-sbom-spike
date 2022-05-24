#!/usr/bin/env bash

[[ -n $TRACE ]] && set -x
set -eo pipefail

source $(dirname $0)/../etc/profile.sh

usage () {
  cat << EOL
`bold USAGE`
    `code $prog` -a `under app`
    `code $prog` -l

`bold DESCRIPTION`
    Build and pack an app in the `code $(basename $appdir)` directory.

    The "build" step would typically be done by a buildpack, however in this
    spike the build is run locally using `code dotnet` commands.

    The "pack" is done using the buildpack in this spike.

`bold WHERE`
    `code app`    app in the `code $(basename $appdir)` directory

`bold OPTIONS`
    `code -a`      app
    `code -l`      list available apps
    `code -h`      print this message

`bold EXAMPLES`
    Pack the webapi-net60 app:
            $ $prog -a webapi-net60
EOL
}

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
  ls -1 $appdir
  exit
fi

apppath=$appdir/$app
[[ -d $apppath ]] || die "app not found: $app"

run () {
  crumb \$ $*
  $*
}

msg "running dotnet restore"
run dotnet restore $apppath

msg "running dotnet build"
run dotnet build --no-restore --configuration Release $apppath

msg "storing app deps"
mkdir -p $apppath/deps
cp $apppath/bin/Release/*/$app.deps.json $apppath/deps

msg "storing framework deps"
# https://github.com/dotnet/runtime/blob/main/docs/design/features/sharedfx-lookup.md
dotnet_home=$(dirname $(command -v dotnet))
rtconfig=$apppath/bin/Release/*/$app.runtimeconfig.json
rtfs=$(jq '.runtimeOptions.frameworks[].name' < $rtconfig | tr -d '"')
for rtf in $rtfs; do
  rtfv=$(jq '.runtimeOptions.frameworks[] | select(.name=="'$rtf'") | .version' < $rtconfig | tr -d '"')
  crumb "storing deps for $rtf $rtfv"
  rtfdeps=$dotnet_home/shared/$rtf/$rtfv/$rtf.deps.json
  cp $rtfdeps $apppath/deps
done

msg "running pack build"
run pack build $app --path $apppath --buildpack $packdir

msg "downloading SBOMs to $sbomdir/$app"
rm -rf  $sbomdir/$app
run pack sbom download $app --output-dir $sbomdir/$app
