To run preparation playbook, run the following cmd:

ansible-playbook -u centos -b -i inventory/preparation/local.ini site-prepare.yml --tags download,preinstall --skip-tags upload,upgrade

Refer to https://stackoverflow.com/questions/40181416/calling-an-ansible-playbook-with-tag-and-parameter
