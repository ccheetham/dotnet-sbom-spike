#!/usr/bin/env bash

[[ -n $TRACE ]] && set -x
set -eo pipefail

source $(dirname $0)/../etc/profile.sh

usage() {
    cat << EOL
USAGE
     $prog template:framework[,framework,...]
     $prog < file

WHERE
     template
             .NET template (run: dotnet new --list for templates)
     framework
             .NET framework, e.g. net6.0
     file    app configuration file (see etc/apps.conf for example)

OPTIONS
     -h      print this message

EXAMPLES
     Generate webapi app for net5.0
             $ $prog webapi:net5.0
     Generate webmvc apps for net5.0 and net6.0:
             $ $prog webmvc:net5,0,net6.0
     Generate apps configured in etc/apps.conf:
             $ $prog < etc/apps.conf
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
    args=()
    while read line; do
        args+=($line)
    done < /dev/stdin
else
    args=$@
fi

for arg in ${args[@]}; do
    template=$(echo $arg | cut -d: -f1)
    frameworks=$(echo $arg | cut -d: -f2 | tr ',' ' ')
    for framework in $frameworks; do
        app="$template-$(echo $framework | tr -d '.')"
        output=$appdir/$app
        msg "creating $app ..."
        rm -rf $output
        dotnet new $template --no-restore --output $output --framework $framework
        msg "... created $app"
    done
done

# vim: ft=bash
