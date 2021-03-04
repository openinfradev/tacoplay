#!/usr/bin/env python3

import os
import subprocess
import sys
import tempfile
import yaml
from pathlib import Path

if len(sys.argv) != 2:
    print("Error: This file needs manifest argument.")
    print("Usage: python chart.py <MANIFEST YAML>")
    exit(1)
manifest = sys.argv[1]
Path("/tmp/charts/").mkdir(parents=True, exist_ok=True)

print("###### Download helm charts")
with open(manifest) as f:
    releases = list(yaml.load_all(f, Loader=yaml.FullLoader))
    for release in releases:
        name = release['spec']['chart']['name']
        version = release['spec']['chart']['version']
        repository = release['spec']['chart']['repository']
        print('helm pull --repo {} --version {} -d /tmp/charts/ {}'.format(repository, version, name))
       
		#print 'name: %s' % name
		#print 'version: %s' % version
		#print 'repository: %s' % repository
		#print('helm template --repo %s --version %s %s') % (repository,version,name)
        process = subprocess.Popen(['helm', 'pull', \
                '--repo', repository, \
                '--version', version, \
                '-d', '/tmp/charts',
                name])
        process.wait()
        chart_filename = '/tmp/charts/'+name+'-'+version+'.tgz'
        untar = subprocess.Popen(['tar', 'xzf', chart_filename, \
                                  '-C', '/tmp/charts', \
                                  '--warning=no-timestamp'])
        untar.wait()
        os.remove(chart_filename)
