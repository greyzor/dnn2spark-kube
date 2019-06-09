#!/bin/bash
#
# https://stackoverflow.com/questions/17998978/removing-colors-from-output
#
sudo kubectl cluster-info | grep "master" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed -e 's/.*https:\/\/\(.*\)/\1/g'