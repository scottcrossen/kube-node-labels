#!/bin/sh
#author scottcrossen

if [[ -z "$1" ]]; then
  echo "Exactly one argument specifying the node label is required"
  exit 1
fi

NODE_LABEL_FILE="$(dirname "${BASH_SOURCE[0]}")"/node-labels.txt

OUTPUT="$(cat "$NODE_LABEL_FILE" | grep "$1" | sed "s|$1=||g")"
if [[ "$?" != "0" ]]; then
  echo "Failed retrieving label"
  exit 1
fi

echo "${OUTPUT:-"NA"}"
