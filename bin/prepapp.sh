#!/usr/bin/env bash

[[ -n $TRACE ]] && set -x
set -eo pipefail

source $(dirname $0)/../etc/profile.sh

usage() {
    cat << EOL
`bold USAGE`
    `code $prog` -s `under template`[:`under framework`[,`under framework`,...]]
    `code $prog` -c `under file`

`bold DESCRIPTION`
    Prepare an app in the `code $(basename $appdir)` directory with the name:
        <`under template`>-<`under framework`>

    Prepared apps can then be built and packed using `code $(basename $bindir)/packapp.sh`.

`bold WHERE`
    `code template`
            .NET template (run `code dotnet new --list` for available templates)
    `code framework`
            .NET framework, e.g. net6.0
    `code file`    app config file (see `code etc/apps.conf` for example)

`bold OPTIONS`
    `code -c`      config file containing app specs
    `code -s`      app spec
    `code -h`      print this message

`bold EXAMPLES`
    Prepare webapi app:
            $ $prog -s webapi

    Prepare webapi app for net6.0:
            $ $prog -s webapi:net6.0

    Prepare webapi apps for net5.0 net6.0:
            $ $prog -s webapi:net5.0,net6.0

    Prepare apps specified in etc/apps.conf:
            $ $prog -c etc/apps.conf
EOL
}

spec=
cfgfile=

while getopts ":c:s:h" opt ; do
    case $opt in
        h)
            usage
            exit
            ;;
        c)
            cfgfile=$OPTARG
            ;;
        s)
            spec=$OPTARG
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

if [[ -z $spec ]] && [[ -z $cfgfile ]]; then
    die "specify either a spec or a config file; run with -h for help"
fi

if [[ -n $spec ]] && [[ -n $cfgfile ]]; then
    die "cannot specify both a spec and a config file; run with -h for help"
fi

if [[ -n $spec ]]; then
    specs=$spec
fi

if [[ -n $cfgfile ]]; then
    specs=$(cat $cfgfile)
fi

for spec in ${specs[@]}; do
    if [[ $spec =~ .*: ]]; then
        template=${spec%:*}
        frameworks=$(echo ${spec#*:} | tr ',' ' ')
    else
        template=$spec
        frameworks=net6.0
    fi
    for framework in $frameworks; do
        app="$template-$(echo $framework | tr -d '.')"
        output=$appdir/$app
        msg "creating $app"
        rm -rf $output
        dotnet new $template --no-restore --output $output --framework $framework
    done
done
