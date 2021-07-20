#!/bin/sh
#author scottcrossen

# This isn't bash so BASH_SOURCE won't work. This is fine as long as the script isn't sourced
NODE_LABEL_SCRIPT="$(dirname "$0")"/label.sh

DEFAULT_VALUE="$1"

TRY_REGION="$("$NODE_LABEL_SCRIPT" topology.kubernetes.io/region)"
if [[ "$?" != "0" ]]; then
  echo "Failed retrieving region"
  exit 1
fi
TRY_ZONE="$("$NODE_LABEL_SCRIPT" topology.kubernetes.io/zone)"
if [[ "$?" != "0" ]]; then
  echo "Failed retrieving zone"
  exit 1
fi
TRY_HOST="$("$NODE_LABEL_SCRIPT" kubernetes.io/hostname)"
if [[ "$?" != "0" ]]; then
  echo "Failed retrieving host"
  exit 1
fi

if [[ -z "$DEFAULT_VALUE" ]]; then
  REGION="${TRY_REGION:+"region=$TRY_REGION"}"
  ZONE="${TRY_ZONE:+"zone=$TRY_ZONE"}"
  HOST="${TRY_HOST:+"host=$TRY_HOST"}"
else
  REGION="region=${TRY_REGION:-"$DEFAULT_VALUE"}"
  ZONE="zone=${TRY_ZONE:-"$DEFAULT_VALUE"}"
  HOST="host=${TRY_HOST:-"$DEFAULT_VALUE"}"
fi

if [[ ! -z "$REGION" ]] && [[ ! -z "$ZONE" ]]; then
  FIRST_COMMA=","
fi

if [[ ! -z "$ZONE" ]] && [[ ! -z "$HOST" ]]; then
  SECOND_COMMA=","
fi

echo "$REGION$FIRST_COMMA$ZONE$SECOND_COMMA$HOST"

exit 0
