#!/bin/bash
if ! which "cake" > /dev/null; then
  node_modules/coffee-script/bin/cake build
else
  cake build
fi
