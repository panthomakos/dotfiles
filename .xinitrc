#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xmodmap ~/.Xmodmap

systemctl --user start syndaemon
systemctl --user start xautolock.service
dropboxd

# Reverse scroll direction on touchpad
xinput set-button-map $(xinput list | egrep "bcm5974" | sed -e 's/^.*id=//' -e 's/\s.*$//') 1 2 3 5 4 6 7 8 9 10 11 12

exec xmonad
