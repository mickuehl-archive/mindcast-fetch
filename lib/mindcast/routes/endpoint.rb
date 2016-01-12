
module Mindcast::Routes
  
  class Endpoint < Sinatra::Application
    
    configure do
      #set :docker_url, lambda { ENV['DOCKER_URL'] || "http://0.0.0.0:6001" }
      #set :registry_url, lambda { ENV['REGISTRY_URL'] || "http://0.0.0.0:5001" }
      #set :repository_home, lambda { ENV['REPOSITORY_HOME'] || "/opt/majordomus/data/repository" }
    end
    
    # just return a simple ACK that the server is alive
    get '/' do
      content_type :json
      status 200
      
      {
        :version => Mindcast::VERSION,
      }.to_json
    end
    
  end
  
end