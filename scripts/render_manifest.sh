#!/bin/bash

cd ${decapod_site_dest}
.github/workflows/render.sh $decapod_base_yaml_version

APPS=$(python <<< "print(' '.join(${taco_apps}))")
for app in $APPS; do
    cp ${site_name}/${app}/${app}-manifest.yaml ${inventory_dir}/
done
