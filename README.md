# Expose Kubernetes Node Labels

Expose node labels to kubernetes pods

## Example:

```
$ cat << EOF | kubectl apply -f -

---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: print-region
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: print-region
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: print-region
subjects:
  - kind: ServiceAccount
    name: print-region
    namespace: default
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: print-region
  namespace: default
---
apiVersion: batch/v1
kind: Job
metadata:
  name: print-region
  namespace: default
spec:
  ttlSecondsAfterFinished: 60
  template:
    metadata:
      labels:
        app: print-region
    spec:
      restartPolicy: Never
      serviceAccountName: print-region
      containers:
      - name: main
        image: alpine
        command:
        - /bin/sh
        args:
        - -c
        - >-
          echo "Hostname:                 '\$(/node-data/label.sh kubernetes.io/hostname)'" && \
          echo "Hostname With Default:    '\$(/node-data/label.sh kubernetes.io/hostname N/A)'" && \
          echo "Nonexistent:              '\$(/node-data/label.sh nonexistent)'" && \
          echo "Nonexistent With Default: '\$(/node-data/label.sh nonexistent N/A)'" && \
          echo "Topology:                 '\$(/node-data/topology.sh)'" && \
          echo "Topology With Default:    '\$(/node-data/topology.sh N/A)'"
        volumeMounts:
        - name: node-data
          mountPath: /node-data
      initContainers:
      - name: init
        image: scottcrossen/kube-node-labels:1.1.0
        imagePullPolicy: IfNotPresent
        env:
        - name: NODE
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: OUTPUT_DIR
          value: /output
        volumeMounts:
        - name: node-data
          mountPath: /output
      volumes:
      - name: node-data
        emptyDir: {}
EOF

# Response:
clusterrole.rbac.authorization.k8s.io/print-region created
clusterrolebinding.rbac.authorization.k8s.io/print-region created
serviceaccount/print-region created
job.batch/print-region created

$ kubectl -n default logs -f jobs/print-region

# Response:
Hostname:                 'minikube'
Hostname With Default:    'minikube'
Nonexistent:              ''
Nonexistent With Default: 'N/A'
Topology:                 'host=minikube'
Topology With Default:    'region=N/A,zone=N/A,host=minikube'
```
