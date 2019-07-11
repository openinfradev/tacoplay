#!/bin/bash
ip addr add 10.10.10.1/24 dev br-ex
ip link set br-ex up
iptables -t nat -A POSTROUTING -o bond0 -j MASQUERADE
