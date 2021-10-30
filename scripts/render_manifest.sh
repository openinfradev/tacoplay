#!/bin/bash

cd ${decapod_site_dest}
.github/workflows/render.sh $decapod_base_yaml_version $site_name

APPS=$(python <<< "print(' '.join(${taco_apps}))")
for app in $APPS; do
    cp decapod-base-yaml/${app}/${site_name}/${app}-manifest.yaml ${inventory_dir}/
done
