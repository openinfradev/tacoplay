
### USAGE : ./04-provision-node.sh {node-name} {config-drive-file}

ironic node-set-provision-state --config-drive $2 $1 active
