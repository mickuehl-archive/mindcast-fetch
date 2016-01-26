
require 'open-uri'
require 'nokogiri'
require 'mindcast/extract'

module Mindcast::Routes
  
  class Endpoint < Sinatra::Application
    
    include Mindcast::Extract
    
    configure do
      #set :docker_url, lambda { ENV['DOCKER_URL'] || "http://0.0.0.0:6001" }
      #set :registry_url, lambda { ENV['REGISTRY_URL'] || "http://0.0.0.0:5001" }
      #set :repository_home, lambda { ENV['REPOSITORY_HOME'] || "/opt/majordomus/data/repository" }
    end
    
    get "/#{Mindcast::API_VERSION}/" do
      content_type :json
      response_status = 200
            
      feed = params['f']
      return empty_response(request.url).to_json if feed == nil or feed == ''
      
      response = {}
      begin
        rss_feed = Nokogiri::HTML(open(feed))
        rss_feed.remove_namespaces!
        
        # extract the data
        data = extract_common_data rss_feed
        links = extract_common_links rss_feed
        items = extract_details rss_feed
        
        # build the response
        _links = {
          :self => request.url
        }
        _data = {
          :type => 'podcast',
          :id => 'x',
          :attributes => data
        }
        _data[:links] = links if links != nil
        _data[:included] = items if items != nil
        
        response = {
          :links => _links,
          :data => _data
        }
        
      rescue Exception => e
        response = error_response request.url, e.message, "500", "500"
        response_status = 500
      end
      
      # send a reply
      status response_status
      return response.to_json
      
    end
    
    private
        
    def empty_response(link)
      {
        :links => {
          :self => link
        },
        :data => []
      }
    end
    
    def data_response(link, type, id, attr, related=nil)
      if related != nil
        data = {
          :links => {
            :self => link,
            :related => related
          },
          :data => {
            :type => type,
            :id => id,
            :attributes => attr
          }
        }
      else
        data = {
          :links => {
            :self => link
          },
          :data => {
            :type => type,
            :id => id,
            :attributes => attr
          }
        }
      end
      
      data
      
    end
    
    def error_response(link, message, status, code)
      {
        :links => {
          :self => link
        },
        :errors => [{
          :status => status,
          :code => code,
          :title => message
          }]
      }
    end
    
  end
  
end