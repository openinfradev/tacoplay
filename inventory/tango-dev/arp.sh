#!/bin/bash
sudo arp -d 90.90.229.26
sudo arp -d 90.90.229.27
sudo arp -d 90.90.229.28
sudo arp -s 90.90.229.26 48:df:37:4d:62:c7
sudo arp -s 90.90.229.27 48:df:37:4b:02:f5
sudo arp -s 90.90.229.28 48:df:37:4b:02:db
