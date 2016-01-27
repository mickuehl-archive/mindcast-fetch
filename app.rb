require 'rubygems'
require 'bundler'
require 'json'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

# Require sinatra basics
require 'sinatra/base'
#require "sinatra/reloader" if development?

# our modules etc
require 'mindcast/version'
require 'mindcast/extract'
require 'mindcast/routes/endpoint'

module Mindcast
  class App < Sinatra::Application
    
    #register Sinatra::ModuleSample
    
    configure do
      # configure app
    end
    
    # include other apps, modules etc
    use Mindcast::Routes::Endpoint
    
  end
end