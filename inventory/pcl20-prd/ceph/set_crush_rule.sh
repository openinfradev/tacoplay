#!/bin/bash

sudo ceph osd crush rule create-replicated ssd default host ssd
sudo ceph osd crush rule create-replicated hdd default rack hdd

sudo ceph osd pool set kube crush_rule ssd
sudo ceph osd pool set images crush_rule ssd
sudo ceph osd pool set volumes-ssd crush_rule ssd
sudo ceph osd pool set volumes-hdd crush_rule hdd
sudo ceph osd pool set lma crush_rule hdd
