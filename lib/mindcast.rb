
require 'json'
require 'yaml'
require 'excon'
require 'docker'

# The top-level module for the Majordomus API
module Mindcast
  
  require 'mindcast/version'
  
  def app_home
    # configure the app
    #ENV['APP_HOME'] || "/opt/majordomus/data/apps"
  end
  
  module_function :app_home
  
end
