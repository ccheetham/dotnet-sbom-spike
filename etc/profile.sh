base_dir=$(realpath $(dirname $0)/..)
bin_dir=$base_dir/bin
cfg_dir=$base_dir/etc
lib_dir=$base_dir/lib
apps_home=$base_dir/apps
sbom_dir=$base_dir/sboms
pack_dir=$base_dir/buildpack

prog=bin/$(basename $0)

source $lib_dir/functions.sh
