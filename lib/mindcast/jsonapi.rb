
require 'open-uri'
require 'nokogiri'
require 'digest/md5'

module Mindcast
  
  module JsonApi
    
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
