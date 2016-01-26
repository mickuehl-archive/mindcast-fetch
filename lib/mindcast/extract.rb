
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
    # items
    XPATH_ITEMS = '//rss/channel/item'
    XPATH_ITEM_LINKS = 'link'
    XPATH_ITEM_TITLE = 'title'
    XPATH_ITEM_SUBTITLE = 'subtitle'
    XPATH_ITEM_AUTHOR = 'author'
    XPATH_ITEM_DESCRIPTION = 'description'
    XPATH_ITEM_SUMMARY = 'summary'
    XPATH_ITEM_DURATION = 'duration'
    XPATH_ITEM_CONTENT = 'enclosure'
    CONTENT_ATTR_URL = 'url'
    CONTENT_ATTR_LENGTH = 'length'
    CONTENT_ATTR_TYPE = 'type'
    
    def extract_common_data(doc)
      
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
        
      rescue Exception => e
        data[:error] = e.message
      end
      
      data
      
    end
    
    def extract_details(doc)
      
      data = []
      
      begin
        items = doc.xpath XPATH_ITEMS
        
        items.each do |item|
          _links = extract_links item, XPATH_ITEM_LINKS
          _content = item.xpath XPATH_ITEM_CONTENT
          
          _attr = {}
          _attr[:title] = extract_xpath(item, XPATH_ITEM_TITLE)
          _attr[:subtitle] = extract_xpath(item, XPATH_ITEM_SUBTITLE) if xpath_exists?(item, XPATH_ITEM_SUBTITLE)
          _attr[:author] = extract_xpath(item, XPATH_ITEM_AUTHOR) if xpath_exists?(item, XPATH_ITEM_AUTHOR)
          _attr[:description] = extract_xpath(item, XPATH_ITEM_DESCRIPTION) if xpath_exists?(item, XPATH_ITEM_DESCRIPTION)
          _attr[:summary] = extract_xpath(item, XPATH_ITEM_SUMMARY) if xpath_exists?(item, XPATH_ITEM_SUMMARY)
          _attr[:duration] = extract_xpath(item, XPATH_ITEM_DURATION) if xpath_exists?(item, XPATH_ITEM_DURATION)
          _attr[:content_url] = _content.attr(CONTENT_ATTR_URL)
          _attr[:content_length] = _content.attr(CONTENT_ATTR_LENGTH)
          _attr[:content_type] = _content.attr(CONTENT_ATTR_TYPE)
          
          i = {
            :type => 'item',
            :id => 'y',
            :attributes => _attr
          }
          i[:links] = _links if _links != nil
          data << i
        end
        
      rescue Exception => e
        puts e.message
      end
      
      return data if !(data.length == 0)
      nil
      
    end
    
    def extract_links(doc, path)
      
      data = {}
    
      begin
        doc.xpath(path).each do |link|
          rel = link.attr('rel')
          data[rel] = link.attr('href') if rel != nil && rel != ''
        end
        
      rescue
      end
      
      return data if !data.empty?
      nil
    end
    
    def extract_common_links(doc)
      return extract_links doc, XPATH_LINKS
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
