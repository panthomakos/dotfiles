# .my.files

Configuration for my entire system.

## Ruby

Ruby is configured via `rbenv` and `ruby-build`. Both projects are git submodules so that I can say on the bleeding-edge.

## System Installation (ArchLinux and MacOSX on x86-64)

I use puppet to automatically configure my system and keep it in a consistent
state. You should only use this command if you want to replicate my entire
system configuration on your own machine.

    git clone https://github.com/panthomakos/dotfiles ~
    ./install.sh
