# .my.files

Basic configuration scripts including the vim setup I use for development.

## Included Vim Plugins (aka @tpope is awesome)

* abolish - http://github.com/tpope/vim-abolish
* commentary - git://github.com/tpope/vim-commentary
* CtrlP - http://github.com/kien/ctrlp.vim
* fugitive - http://github.com/tpope/vim-fugitive
* haml - http://github.com/tpope/vim-haml
* markdown - https://github.com/tpope/vim-markdown
* surround - http://github.com/tpope/vim-surround
* tabular - https://github.com/godlygeek/tabular
* unimpaired - http://github.com/tpope/vim-unimpaired

## System Installation

I use puppet to automatically configure my system and keep it in a consistent
state. You should only use this command if you want to replicate my entire
system configuration on your own machine.

    git clone git@github.com:panthomakos/dotfiles ~/
    rake
