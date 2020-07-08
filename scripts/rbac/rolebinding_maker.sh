#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <ENVIRONMENT> <NAMESPACE> <ROLE>"
  exit -1
fi

ENV=$1
NAMESPACE=$2
ROLE=$3

kubectl get ns $NAMESPACE > /dev/null 2>&1

if [ $? -eq 1 ]; then
  kubectl create ns $NAMESPACE
fi

if [ $ROLE == "view" ] || [ $ROLE == "admin" ]; then

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $NAMESPACE-$ROLE
  namespace: $NAMESPACE
subjects:
- kind: Group
  name: app-$ROLE
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: $ENV-app-$ROLE
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: $NAMESPACE-app-$ROLE
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: $ENV-$NAMESPACE-app-$ROLE
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: $NAMESPACE-$ROLE
  apiGroup: rbac.authorization.k8s.io
EOF

else
  echo "Only support \"admin\", \"view\" role."
  exit -1
fi
