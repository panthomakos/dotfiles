Pry.config.commands.command('rails', 'Load the rails console.') do
  env = File.join Dir.getwd, 'config', 'environment.rb'

  if File.exists?(env)
    require env
    require 'rails/console/app'
    require 'rails/console/helpers'
  end
end
