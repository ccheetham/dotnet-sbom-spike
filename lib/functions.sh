cli_red="tput setaf 1"
cli_green="tput setaf 2"
cli_reset="tput sgr0"

die () {
  $cli_red
  echo $*
  $cli_reset
  tput sgr0
  exit 1
}

msg () {
  $cli_green
  echo $*
  $cli_reset
}
