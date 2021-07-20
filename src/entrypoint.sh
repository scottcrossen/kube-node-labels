#!/bin/sh
#author scottcrossen

if [[ -z "$NODE" ]]; then
  echo "Required environment variable 'NODE' is missing"
  exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  echo "Required environment variable 'OUTPUT_DIR' is missing"
  exit 1
fi

if ! touch "$OUTPUT_DIR"/labels.txt; then
  echo "Failed creating output file"
  exit 1
fi

if ! cp /node-label.sh "$OUTPUT_DIR"/label.sh; then
  echo "Failed moving helper script 'label.sh'"
  exit 1
fi

if ! cp /node-topology.sh "$OUTPUT_DIR"/topology.sh; then
  echo "Failed moving helper script 'topology.sh'"
  exit 1
fi

API_RESPONSE="$(wget \
    --ca-certificate=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --header="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    --header="Accept: application/json" \
    -O - \
    https://kubernetes.default.svc.cluster.local/api/v1/nodes/"$NODE")"
if [[ "$?" != "0" ]]; then
  echo "Failed getting API response"
  echo "$API_RESPONSE"
  exit 1
fi

JQ_RESPONSE="$(echo "$API_RESPONSE" | \
  jq -r '
    {
      "failure-domain.beta.kubernetes.io/region": .metadata.labels["topology.kubernetes.io/region"],
      "failure-domain.beta.kubernetes.io/zone": .metadata.labels["topology.kubernetes.io/zone"],
      "topology.kubernetes.io/region": .metadata.labels["failure-domain.beta.kubernetes.io/region"],
      "topology.kubernetes.io/zone": .metadata.labels["failure-domain.beta.kubernetes.io/zone"]
    } * {
      "failure-domain.beta.kubernetes.io/region": "",
      "failure-domain.beta.kubernetes.io/zone": "",
      "topology.kubernetes.io/region": "",
      "topology.kubernetes.io/zone": ""
    } * .metadata.labels
  | to_entries
  | map("\(.key)=\(.value|tostring)")
  | .[]')"
if [[ "$?" != "0" ]]; then
  echo "Failed getting JQ response"
  echo "$JQ_RESPONSE"
  exit 1
fi

echo "$JQ_RESPONSE" > "$OUTPUT_DIR"/labels.txt
if [[ "$?" != "0" ]]; then
  echo "Failed writing file"
  exit 1
fi

exit 0
