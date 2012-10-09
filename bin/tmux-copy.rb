#!/usr/bin/env ruby

# If process is already running, exit. I use 2 here because this process
# will have the same name as the currently running process.
if `ps -ef | grep tmux-copy | grep -sv grep | wc -l`.strip.to_i >= 2
  exit(0)
end

Process.daemon

$0 = 'tmux-copy'

loop do
  if system('tmux showb > /dev/null')
    system('tmux saveb -|pbcopy && tmux deleteb')
  end
  sleep 0.5
end
