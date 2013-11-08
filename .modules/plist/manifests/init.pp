class plist inherits user {
  file {
    "${home}/Library/Preferences/com.mizage.Divvy.plist":
      ensure => link,
      target => "${home}/.plist/com.mizage.Divvy.plist",
  }

  file {
    "${home}/Library/Preferences/com.googlecode.iterm2.plist":
      ensure => link,
      target => "${home}/.plist/com.googlecode.iterm2.plist",
  }
}
