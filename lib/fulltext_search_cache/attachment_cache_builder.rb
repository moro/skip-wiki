#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 filetype=ruby
# $KCODE = 'u'

require 'rubygems'
#require File.expand_path("..", File.dirname(__FILE__))

class FulltextSearchCache
  class AttachmentCacheBuilder
    include MetaWriter

    def initialize(attachment, url_prefix)
      @attachment = attachment
      @url_prefix = url_prefix
    end

    def filename
      "attachment/#{@attachment.filename}"
    end

    def write_cache(mediator)
      FileUtils.ln_s(@attachment.full_filename, mediator.cache_path(self), :force => true)
    end

    def to_meta
      publicities = ["note:#{@attachment.attachable_id}"]
      publicities << "public" if @attachment.attachable.public_readable?
      {
        :title => @attachment.display_name,
        :contents_type => "knowledge-attachment",
        :publication_symbols => publicities.join(" "),
        :link_url => URI.join(@url_prefix, "notes/#{ERB::Util.u(@attachment.attachable.name)}/attachments/#{ERB::Util.u(@attachment.id)}").to_s,
        :icon_url => URI.join(@url_prefix, "/icons/attachment.gif").to_s,
      }
    end
  end
end

