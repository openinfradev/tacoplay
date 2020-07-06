#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <ENVIRONMENT>"
  exit -1
fi

ENV=$1

ROLES=("admin" "view")

for role in ${ROLES[@]}
do
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $ENV-cluster-$role
subjects:
- kind: Group
  name: cluster-$role
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: $ENV-cluster-$role
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: $role
  apiGroup: rbac.authorization.k8s.io
EOF
done
