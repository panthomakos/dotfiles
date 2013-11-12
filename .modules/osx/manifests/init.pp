class osx inherits user {
  define osx_default($domain, $key, $value, $type, $expect = $value){
    $command = "defaults write ${domain} '${key}' -${type} ${value}"

    if ($expect == $value) {
      exec {
        $command:
        onlyif => "test `defaults read ${domain} ${key}` -ne ${value}",
      }
    } else {
      $file = "/tmp/osx.test.${domain}.${key}"

      file {
        $file:
          source => $expect,
          ensure => present,
      }

      exec {
        $command:
        onlyif => "test `diff <(defaults read ${domain} ${key}) <(cat {$file} > /dev/null ; echo $?` -ne 0",
        require => File[$file],
      }
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

  osx_default {
    'set google chrome shortcuts':
      domain => 'com.google.Chrome',
      key => 'NSUserKeyEquivalents',
      value => '"Open File..." "@" "Open Location..." "@o" "Select Next Tab" "@l" "Select Previous Tab" "@h"',
      expect => 'puppet:///modules/osx/chrome.keys',
      type => 'dict',
  }
}
