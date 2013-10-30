#!/bin/sh

command_exist() {
  hash $1 2>/dev/null
}

if command_exist sw_vers; then # Mac
  sh ./mac-pre-install.sh
elif command_exist lscpu; then # Linux
  sh ./ubuntu-pre-install.sh
fi

exit 0