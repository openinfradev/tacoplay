#!/bin/sh

ceph --cluster hdd_ceph osd pool set-quota hdd_lma max_bytes 1979120929996
