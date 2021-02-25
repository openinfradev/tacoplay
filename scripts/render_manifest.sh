#!/bin/bash
app=$1
site=$(echo ${inventory_dir} | awk -F '/' '{print $NF}')
cd ${decapod-site-yaml_dest}
.github/workflows/render.sh $app
cp ${app}/output/${site}/${app}-manifest.yaml ${inventory_dir}/
