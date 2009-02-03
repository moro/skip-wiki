require 'erb'

class FulltextSearchCache
  class NoteCacheBuilder
    include EntityContentCache
    include MetaWriter
    def initialize(note, url_prefix)
      @note = note
      @url_prefix = url_prefix
    end

    def filename
      "note/#{@note.id}.html"
    end

    def title; @note.display_name ; end
    def body;  @note.description ; end

    def to_meta
      publicities = ["note:#{@note.id}"]
      publicities << "public" if @note.public_readable?
      {
        :title => @note.display_name,
        :contents_type => "knowledge-note",
        :publification_symbols => publicities.join(" "),
        :url => URI.join(@url_prefix, "notes/#{ERB::Util.u(@note.name)}").to_s,
        :icon_url => URI.join(@url_prefix, "icons/note.gif").to_s,
      }
    end

  end
end
