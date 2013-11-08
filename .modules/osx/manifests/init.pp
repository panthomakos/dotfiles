class osx inherits user {
  define osx_default($domain, $key, $value, $type){
    exec {
      "defaults write ${domain} '${key}' -${type} '${value}'":
      onlyif => "test `defaults read ${domain} ${key}` -ne ${value}",
    }
  }

  exec { 'killall Dock': refreshonly => true }

  osx_default {
    'key repeat delay':
      domain => 'NSGlobalDomain',
      key => 'InitialKeyRepeat',
      value => 15,
      type => 'int',
  }

  osx_default {
    'key repeat rate':
      domain => 'NSGlobalDomain',
      key => 'KeyRepeat',
      value => 2,
      type => 'int',
  }

  osx_default {
    'dock icon size':
      domain => 'com.apple.dock',
      key => 'tilesize',
      value => 16,
      type => 'int',
      notify => Exec['killall Dock'],
  }

  osx_default {
    'prevent launchpad from reappearing':
      domain => 'com.apple.dock',
      key => 'checked-for-launchpad',
      value => true,
      type => 'bool',
      notify => Exec['killall Dock'],
  }

  osx_default {
    'remove pinned icons':
      domain => 'com.apple.dock',
      key => 'persistent-apps',
      value => '()',
      type => 'array',
      notify => Exec['killall Dock'],
  }
}
