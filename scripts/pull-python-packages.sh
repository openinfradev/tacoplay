#!/bin/bash
#set -x

mkdir $TACOPLAY_DIR/mirrors/pip
pip download --dest $TACOPLAY_DIR/mirrors/pip -r $TACOPLAY_DIR/requirements.txt
pip download --dest $TACOPLAY_DIR/mirrors/pip -r $TACOPLAY_DIR/kubespray/requirements.txt
pip download --dest $TACOPLAY_DIR/mirrors/pip pip==9.0.3 \
  virtualenv \
  virtualenvwrapper \
  pbr \
  python-openstackclient==3.16.0 \
  python-cinderclient==3.3.0 \
  python-glanceclient==2.8.0 \
  python-keystoneclient==3.17.0 \
  python-novaclient==9.1.2 \
  docker==3.5.1 \
  pypiserver
pip download --dest $TACOPLAY_DIR/mirrors/pip python-cinderclient==3.1.0
pip3.4 download --dest $TACOPLAY_DIR/mirrors/pip -r $TACOPLAY_DIR/armada/requirements.txt
