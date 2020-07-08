#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <NAMESPACE>"
  exit -1
fi

NAMESPACE=$1

kubectl get ns $NAMESPACE

if [ $? -eq 1 ]; then
  kubectl create ns $NAMESPACE
fi
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $NAMESPACE
  name: $NAMESPACE-admin
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $NAMESPACE
  name: $NAMESPACE-view
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["*"]
  verbs: ["get", "watch", "list","log"]
EOF
