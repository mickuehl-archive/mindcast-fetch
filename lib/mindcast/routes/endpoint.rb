
require 'open-uri'
require 'nokogiri'
require 'mindcast/extract'
require 'mindcast/jsonapi'

module Mindcast::Routes

  class Endpoint < Sinatra::Application

    include Mindcast::Extract
    include Mindcast::JsonApi

    configure do
      # configure the endpoint ...
    end

    get '/' do
      content_type :json
      response_status = 200

      feed = params['f']
      return empty_response(request.url).to_json if feed == nil or feed == ''

      response = {}
      begin
        rss_feed = Nokogiri::HTML(open(feed))
        rss_feed.remove_namespaces!

        # extract the data
        data = extract_podcast rss_feed
        links = extract_links rss_feed, XPATH_LINKS
        episodes = extract_episodes(rss_feed, feed)

        # build the response
        _links = {
          :self => request.url
        }
        _data = {
          :type => 'podcast',
          :id => hash(feed + data[:title]),
          :attributes => data
        }
        _data[:links] = links if links != nil
        _data[:included] = episodes if episodes != nil

        response = {
          :links => _links,
          :data => _data
        }

      rescue Exception => e
        puts e.message
        puts e.backtrace
        response = error_response request.url, e.message, "500", "500"
        response_status = 500
      end

      # send a reply
      status response_status
      return response.to_json

    end

    get '/info' do
      content_type :json
      response_status = 200

      response = data_response(request.url,'info',0,{:version => Mindcast::VERSION})

      # send a reply
      status response_status
      return response.to_json
    end

  end

end
