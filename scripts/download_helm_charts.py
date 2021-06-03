#!/usr/bin/env python3

import os
import subprocess
import sys
import tempfile
import yaml
from pathlib import Path

if len(sys.argv) != 3:
    print("Error: This file needs manifest argument.")
    print("Usage: python chart.py <MANIFEST YAML> <download dir>")
    exit(1)
manifest = sys.argv[1]
download_dir = sys.argv[2]+'/'
Path(download_dir).mkdir(parents=True, exist_ok=True)

print("###### Download helm charts")
with open(manifest) as f:
    releases = list(yaml.load_all(f, Loader=yaml.FullLoader))
    for release in releases:
        name = release['spec']['chart']['name']
        version = release['spec']['chart']['version']
        repository = release['spec']['chart']['repository']
        print('helm pull --repo {} --version {} -d {} {}'.format(repository, version, download_dir, name))
       
		#print 'name: %s' % name
		#print 'version: %s' % version
		#print 'repository: %s' % repository
		#print('helm template --repo %s --version %s %s') % (repository,version,name)
        process = subprocess.Popen(['helm', 'pull', \
                '--repo', repository, \
                '--version', version, \
                '-d', download_dir, \
                name])
        process.wait()
        chart_filename = download_dir+name+'-'+version+'.tgz'
        untar = subprocess.Popen(['tar', 'xzf', chart_filename, \
                                  '-C', download_dir, \
                                  '--warning=no-timestamp'])
        untar.wait()
        os.remove(chart_filename)
