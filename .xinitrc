#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xmodmap ~/.Xmodmap
setxkbmap -option 'caps:ctrl_modifier'
xcape -e 'Caps_Lock=Escape'

systemctl --user start syndaemon
systemctl --user start xautolock.service

# Reverse scroll direction on touchpad
xinput set-button-map $(xinput list | egrep "bcm5974" | sed -e 's/^.*id=//' -e 's/\s.*$//') 1 2 3 5 4 6 7 8 9 10 11 12

# Accelerate the mouse a bit.
xset m 3/1 4

exec xmonad
