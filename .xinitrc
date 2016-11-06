#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

keyboard

systemctl --user start xautolock.service

# Accelerate the mouse a bit.
xset m 3/1 4

exec xmonad
