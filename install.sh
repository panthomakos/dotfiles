#!/bin/sh

which ansible-playbook || sudo pacman -S ansible

pushd $HOME/ansible
ansible-playbook -K -i inventory playbook.yml
popd
