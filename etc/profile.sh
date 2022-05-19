basedir=$(realpath $(dirname $0)/..)
bindir=$basedir/bin
cfgdir=$basedir/etc
libdir=$basedir/lib
appdir=$basedir/apps

prog=bin/$(basename $0)

source $libdir/functions.sh
