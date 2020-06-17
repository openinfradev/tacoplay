#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: $0 <NAMESPACE> <GROUP> <ROLE>"
	exit -1
fi

NAMESPACE=$1
GROUP=$2
ROLE=$3

kubectl get ns $NAMESPACE > /dev/null 2>&1

if [ $? -eq 1 ]; then
	kubectl create ns $NAMESPACE
fi

if [ $ROLE == "viewer" ] || [ $ROLE == "admin" ]; then

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $NAMESPACE-$ROLE
  namespace: $NAMESPACE
subjects:
# You can specify more than one "subject"
- kind: Group
  name: $GROUP
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: $NAMESPACE-$ROLE # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

else
	echo "Only support \"admin\", \"viewer\" role."
	exit -1
fi
