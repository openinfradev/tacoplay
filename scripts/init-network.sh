#!/bin/bash
ip addr add 10.10.10.1/24 dev br-ex
ip link set br-ex up
iptables -A FORWARD -o br-ex -j ACCEPT
iptables -A FORWARD -o bond0 -j ACCEPT
iptables -t nat -A POSTROUTING -o bond0 -j MASQUERADE
