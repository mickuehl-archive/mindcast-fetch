
require 'open-uri'
require 'nokogiri'
require 'digest/md5'

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
    # episodes
    XPATH_ITEMS = '//rss/channel/item'
    XPATH_ITEM_LINKS = 'link'
    XPATH_ITEM_TITLE = 'title'
    XPATH_ITEM_SUBTITLE = 'subtitle'
    XPATH_ITEM_AUTHOR = 'author'
    XPATH_ITEM_DESCRIPTION = 'description'
    XPATH_ITEM_GUID = 'guid'
    XPATH_ITEM_SUMMARY = 'summary'
    XPATH_ITEM_DURATION = 'duration'
    XPATH_ITEM_CONTENT = 'enclosure'
    CONTENT_ATTR_URL = 'url'
    CONTENT_ATTR_LENGTH = 'length'
    CONTENT_ATTR_TYPE = 'type'
    # chapters
    XPATH_CHAPTERS = 'chapters'
    XPATH_CHAPTER = 'chapter'

    def extract_podcast(doc)

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

    def extract_episodes(doc, feed)
      data = []

      begin
        items = doc.xpath XPATH_ITEMS

        items.each do |item|
          _links = extract_links item, XPATH_ITEM_LINKS
          _content = item.xpath XPATH_ITEM_CONTENT

          if _content.length != 0
            # only if there is actually content
            _attr = {}
            _attr[:guid] = extract_xpath(item, XPATH_ITEM_GUID) if xpath_exists?(item, XPATH_ITEM_GUID)
            _attr[:title] = extract_xpath(item, XPATH_ITEM_TITLE)
            _attr[:subtitle] = extract_xpath(item, XPATH_ITEM_SUBTITLE) if xpath_exists?(item, XPATH_ITEM_SUBTITLE)
            _attr[:author] = extract_xpath(item, XPATH_ITEM_AUTHOR) if xpath_exists?(item, XPATH_ITEM_AUTHOR)
            _attr[:description] = extract_xpath(item, XPATH_ITEM_DESCRIPTION) if xpath_has_content?(item, XPATH_ITEM_DESCRIPTION)
            _attr[:summary] = extract_xpath(item, XPATH_ITEM_SUMMARY) if xpath_has_content?(item, XPATH_ITEM_SUMMARY)
            _attr[:duration] = duration( extract_xpath(item, XPATH_ITEM_DURATION)) if xpath_exists?(item, XPATH_ITEM_DURATION)

            _attr[:content_url] = _content.attr(CONTENT_ATTR_URL)
            _attr[:content_length] = (_content.attr(CONTENT_ATTR_LENGTH).to_s).to_i
            _attr[:content_type] = _content.attr(CONTENT_ATTR_TYPE)

            # check if there are chapter notes (xmlns:psc="http://podlove.org/simple-chapters")
            _chapters = extract_chapters item, feed

            # complete the object
            i = {
              :type => 'episode',
              :id => hash(feed + _attr[:title]),
              :attributes => _attr
            }
            i[:links] = _links if _links != nil
            i[:included] = _chapters if _chapters != nil

            data << i
          end
        end

      rescue Exception => e
        puts e.backtrace
        i[:error] = e.message
        data << i
      end

      return data if data.length != 0
      nil

    end

    def extract_chapters(item, feed)
      data = []
      chapters = item.xpath(XPATH_CHAPTERS)

      return nil if chapters.length == 0

      begin
        chapters.xpath(XPATH_CHAPTER).each do |chapter|
          start = chapter.attr('start')
          title = chapter.attr('title')
          data << {
            :type => 'chapter',
            :id => hash(feed, title),
            :attributes => {
              :start => start,
              :title => title
            }
          }
        end
      rescue
        #puts e.backtrace
      end

      return data if data.length != 0
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

    def xpath_has_content?(root, path)
      begin
        e = root.xpath path
        return false if e == nil or e.length == 0
        return false if e.text.empty?
      rescue
        return false
      end
      return true
    end

    def hash(s1,s2='')
      return Digest::MD5.hexdigest(s1 + s2)
    end

    def duration(s)
      parts = s.split(':')
      case parts.length
        when 1 # sec
          return parts[0].to_i
        when 2 # min:sec
          return (parts[0].to_i * 60) + parts[1].to_i
        when 3 # hour:min:sec
          return (parts[0].to_i * 3600) + (parts[1].to_i * 60) + parts[2].to_i
      end
    end

  end
end
