#!/bin/bash
app=$1

cd ${decapod_site_yaml_dest}
.github/workflows/render.sh $app $decapod_base_yaml_version
cp ${app}/output/${site_name}/${app}-manifest.yaml ${inventory_dir}/
