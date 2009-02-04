require 'erb'
require 'yaml'

class FulltextSearchCache
  class PageCacheBuilder
    include EntityContentCache
    include MetaWriter
    def initialize(page, url_prefix)
      @page = page
      @url_prefix = url_prefix
    end

    def filename
      "page/#{@page.id}.html"
    end

    def title; @page.display_name ; end
    def body; @page.content ; end

    def to_meta
      publicities = ["note:#{@page.note_id}"]
      publicities << "public" if @page.published? && @page.note.public_readable?
      {
        :title => @page.display_name,
        :contents_type => "knowledge-note",
        :publification_symbols => publicities.join(" "),
        :url => URI.join(@url_prefix, "notes/#{ERB::Util.u(@page.note.name)}/pages/#{ERB::Util.u(@page.name)}").to_s,
        :icon_url => URI.join(@url_prefix, "icons/page.gif").to_s,
      }
    end
  end
end
