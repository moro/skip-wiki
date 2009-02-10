require 'erb'

class FulltextSearchCache
  class NoteCacheBuilder
    include EntityContentCache
    include MetaWriter

    def initialize(note)
      @note = note
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
        :publication_symbols => publicities.join(" "),
        :link_url => url_for(:controller => "notes", :action => "show", :id => @note),
        :icon_url => icon_url("note.gif")
      }
    end
  end
end
