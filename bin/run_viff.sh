#!/usr/bin/env bash

run_diff() {
  arr=($1 $2)
  jpg_arr=()

  for file in ${arr[@]}; do

    name=`echo $file | cut -d '.' -f1`
    convert "$name.png" -background white -alpha remove -resize 30% "$name.jpg"
    jpg_arr=(${jpg_arr[@]} "$name.jpg")

    if [ -f $file ]; then
      rm $file
    fi

  done
  output_name=`echo $3 | cut -d '.' -f1`
  compare "${jpg_arr[0]}" "${jpg_arr[1]}" "$output_name.jpg"
}

if [ ! -z $1 ]; then
  if [ ! -z $2 ]; then
    if [ ! -z $3 ]; then
      run_diff "$1" "$2" "$3"
      exit 0
    fi
  fi
fi
echo "Invalid command"
exit 1
