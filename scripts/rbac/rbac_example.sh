#!/bin/bash
TACOPLAY_HOME=/home/taco

ENV="dev"
NS=("app1" "app2" "app3")
ROLES=("admin" "view")

$TACOPLAY_HOME/tacoplay/scripts/rbac/clusterrolebinding_maker.sh $ENV

for ns in ${NS[@]}
do
  $TACOPLAY_HOME/tacoplay/scripts/rbac/role_maker.sh $ns
  for role in ${ROLES[@]}
  do
    $TACOPLAY_HOME/tacoplay/scripts/rbac/rolebinding_maker.sh $ENV $ns $role
  done
done
