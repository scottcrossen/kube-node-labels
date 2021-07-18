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

if ! touch "$OUTPUT_DIR"/node-labels.txt; then
  echo "Failed creating output file"
  exit 1
fi

if ! cp /node-label.sh "$OUTPUT_DIR"/node-label.sh; then
  echo "Failed moving helper script"
  exit 1
fi

if ! wget \
    --ca-certificate=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --header="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    --header="Accept: application/json" \
    -O - \
    https://kubernetes.default.svc.cluster.local/api/v1/nodes/"$NODE" | \
  jq -r '
{
  "failure-domain.beta.kubernetes.io/region": .metadata.labels["topology.kubernetes.io/region"],
  "failure-domain.beta.kubernetes.io/zone": .metadata.labels["topology.kubernetes.io/zone"],
  "topology.kubernetes.io/region": .metadata.labels["failure-domain.beta.kubernetes.io/region"],
  "topology.kubernetes.io/zone": .metadata.labels["failure-domain.beta.kubernetes.io/zone"]
} * {
  "failure-domain.beta.kubernetes.io/region": "NA",
  "failure-domain.beta.kubernetes.io/zone": "NA",
  "topology.kubernetes.io/region": "NA",
  "topology.kubernetes.io/zone": "NA"
} * .metadata.labels
  | to_entries
  | map({key: .key, value: (if .value == "" then "NA" else .value end)})
  | map("\(.key)=\(.value|tostring)")
  | .[]' > "$OUTPUT_DIR"/node-labels.txt; then
  echo "Failed getting node labels"
  exit 1
fi

exit 0