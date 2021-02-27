#!/bin/bash
app=$1

cd ${decapod_site_yaml_dest}
.github/workflows/render.sh $app
cp ${app}/output/${site_name}/${app}-manifest.yaml ${inventory_dir}/
