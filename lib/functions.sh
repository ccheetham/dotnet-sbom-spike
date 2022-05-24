cli_red="tput setaf 1"
cli_green="tput setaf 2"
cli_yellow="tput setaf 3"
cli_reset="tput sgr0"

die () {
  red $*
  exit 1
}

msg () {
  $cli_green
  echo $*
  $cli_reset
}

red () {
  $cli_red
  echo $*
  $cli_reset
}

crumb () {
  $cli_yellow
  echo $*
  $cli_reset
}

bold () {
  tput bold
  printf "%s" "$*"
  tput sgr0
}

under () {
  tput smul
  printf "%s" "$*"
  tput rmul
}

code () {
  bold $*
}
