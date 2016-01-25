
require 'open-uri'
require 'nokogiri'

module Mindcast
  
  module Extract
    
    # namespaces
    NS_ITUNES     = 'itunes'
    NS_ATOM       = 'atom'
    NS_ITUNES_URL = 'http://www.itunes.com/dtds/podcast-1.0.dtd'
    NS_ATOM_URL   = 'http://www.w3.org/2005/Atom'
    NS_BITLOVE    = 'bitlove'
    NS_BITLOVE_URL  = 'http://bitlove.org'
    
    # top-level
    XPATH_CHANNEL = '//rss/channel'
    # details
    XPATH_TITLE = '//rss/channel/title'           # title
    XPATH_SUB_TITLE = '//rss/channel/subtitle'    # itunes:subtitle
    XPATH_SUMMARY = '//rss/channel/summary'
    XPATH_DESCRIPTION = '//rss/channel/description'
    XPATH_IMAGE = '//rss/channel/image'
    XPATH_LANGUAGE = '//rss/channel/language'
    XPATH_COPYRIGHT = '//rss/channel/copyright'
    XPATH_GENERATOR = '//rss/channel/generator'
    XPATH_OWNER_NAME = '//rss/channel/owner/name'
    XPATH_OWNER_EMAIL = '//rss/channel/owner/email'
    XPATH_AUTHOR = '//rss/channel/author'
    # links
    XPATH_LINKS = '//rss/channel/link'
    
    def extract_data(doc)
      
      data = {}
      
      begin
        
        data[:title] = extract_xpath doc, XPATH_TITLE
        data[:subtitle] = extract_xpath doc, XPATH_SUB_TITLE
        data[:summary] = extract_xpath doc, XPATH_SUMMARY
        data[:description] = extract_xpath doc, XPATH_DESCRIPTION
        data[:image] = extract_image doc if xpath_exists? doc, XPATH_IMAGE
        data[:author] = extract_xpath doc, XPATH_AUTHOR if xpath_exists? doc, XPATH_AUTHOR
        data[:owner_name] = extract_xpath doc, XPATH_OWNER_NAME if xpath_exists? doc, XPATH_OWNER_NAME
        data[:owner_email] = extract_xpath doc, XPATH_OWNER_EMAIL if xpath_exists? doc, XPATH_OWNER_EMAIL
        data[:language] = extract_xpath doc, XPATH_LANGUAGE if xpath_exists? doc, XPATH_LANGUAGE
        data[:copyright] = extract_xpath doc, XPATH_COPYRIGHT if xpath_exists? doc, XPATH_COPYRIGHT
        data[:generator] = extract_xpath doc, XPATH_GENERATOR if xpath_exists? doc, XPATH_GENERATOR
        #data[:subtitle] = extract_xpath channel, XPATH_SUB_TITLE
        
      rescue Exception => e
        data[:error] = e.message
      end
      
      data
      
    end
    
    def extract_links(doc)
      
      data = {}
      
      begin
        links = doc.xpath XPATH_LINKS
        
        links.each do |link|
          rel = link.attr('rel') 
          data[rel] = link.attr('href') if rel != nil && rel != ''
        end
        
      rescue
      end
      
      return data if !data.empty?
      nil
    end
    
    def extract_image(root)
      images = root.xpath XPATH_IMAGE
      images.each do |image|
        return image.attr('href') if image.attr('href') != nil
      end
      return nil
    end
    
    def extract_xpath(root, path, default='')
      begin
        t = root.xpath(path).text
        return default if t == nil or t == ''
      rescue
        t = default
      end
      return t
    end
    
    def xpath_exists?(root, path)
      begin
        e = root.xpath path
        return false if e == nil or e.length == 0
      rescue
        return false
      end
      return true
    end
    
  end
end
