# Expose Kubernetes Node Labels

Expose node labels to kubernetes pods

## Example:

```
containers:
- name: my-deployment
  command:
  - /bin/sh
  args:
  - -c
  - >-
    exec some-command
    --region "$(cat /node-labels/labels | grep 'topology.kubernetes.io/region' | sed 's|topology.kubernetes.io/region=||g')"
  volumeMounts:
  - name: node-labels
    mountPath: /node-labels
initContainers:
- name: query-node-info
  image: scrossen/kube-node-labels:latest
  imagePullPolicy: IfNotPresent
  env:
  - name: NODE
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  env:
    name: OUTPUT
    value: /output/labels
  volumeMounts:
  - name: node-labels
    mountPath: /output
volumes:
- name: node-labels
  emptyDir: {}
```
