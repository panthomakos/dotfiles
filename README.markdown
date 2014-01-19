# .my.files

Configuration for my entire system.

## Included Vim Plugins (aka @tpope is awesome)

* fugitive - http://github.com/tpope/vim-fugitive
* unimpaired - http://github.com/tpope/vim-unimpaired
* haml - http://github.com/tpope/vim-haml
* surround - http://github.com/tpope/vim-surround
* tabular - https://github.com/godlygeek/tabular
* commentary - git://github.com/tpope/vim-commentary
* markdown - https://github.com/tpope/vim-markdown
* abolish - http://github.com/tpope/vim-abolish
* CtrlP - http://github.com/kien/ctrlp.vim

## Ruby

Ruby is configured via `rbenv` and `ruby-build`. Both projects are git submodules so that I can say on the bleeding-edge.

## System Installation (ArchLinux and MacOSX on x86-64)

I use puppet to automatically configure my system and keep it in a consistent
state. You should only use this command if you want to replicate my entire
system configuration on your own machine.

    git clone https://github.com/panthomakos/dotfiles ~
    ./install.sh
