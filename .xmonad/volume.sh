#!/bin/sh

output=`amixer get -D pulse Master`
percent=`echo ${output} | egrep -o "[0-9]+%" | tail -n 1`
toggle=`echo ${output} | egrep -o "(on|off)" | tail -n 1`

if [[ $toggle == 'on' ]]; then
  echo $percent
else
  echo "MUTE"
fi

exit 0
