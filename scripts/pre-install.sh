#!/bin/sh

command_exist() {
  hash $1 2>/dev/null
}

if command_exist sw_vers; then # Mac
  sudo sh ./mac-pre-install.sh
elif command_exist lscpu; then # Linux
  sudo sh ./ubuntu-pre-install.sh
fi

exit 0