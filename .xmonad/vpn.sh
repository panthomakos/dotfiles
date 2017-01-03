#!/bin/sh

output=`systemctl | grep 'openvpn-client@' | grep 'active' | awk '{print \$1}'`
regex="openvpn-client@(.+)\.service"

if [[ $output =~ $regex ]]; then
  echo ${BASH_REMATCH[1]}
elif [[ ! -z $output ]]; then
  echo $output
else
  echo "no vpn"
fi

exit 0
