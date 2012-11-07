#!/usr/bin/env ruby

if File.exists?('.zeus.sock')
  exec('zeus', *ARGV)
else
  exec('bundle exec', *ARGV)
end
