#!/bin/sh
#author scottcrossen

if [[ -z "$1" ]]; then
  echo "One argument specifying the node label is required"
  exit 1
fi

DEFAULT_VALUE="$2"

# This isn't bash so BASH_SOURCE won't work. This is fine as long as the script isn't sourced
NODE_LABEL_FILE="$(dirname "$0")"/labels.txt

OUTPUT="$(cat "$NODE_LABEL_FILE" | grep "$1" | sed "s|$1=||g")"
if [[ "$?" != "0" ]]; then
  echo "Failed retrieving label"
  exit 1
fi

echo "${OUTPUT:-"$DEFAULT_VALUE"}"

exit 0
