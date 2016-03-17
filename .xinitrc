#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

setxkbmap -option 'caps:ctrl_modifier'
xcape -e 'Caps_Lock=Escape'
xmodmap ~/.Xmodmap

systemctl --user start syndaemon
systemctl --user start xautolock.service

# Accelerate the mouse a bit.
xset m 3/1 4

exec xmonad
