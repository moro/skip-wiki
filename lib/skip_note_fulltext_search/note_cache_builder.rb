require 'erb'
require 'skip_collabo/fulltext_search_cache/builder_base'

module SkipNoteFulltextSearch
  class NoteCacheBuilder < SkipCollabo::FulltextSearchCache::BuilderBase
    self.entity_name = "note"

    def title; ERB::Util.h(note.display_name) ; end
    def body;  ERB::Util.h(note.description) ; end

    def to_meta
      publicities = ["note:#{note.id}"]
      publicities << "public" if note.public_readable?
      {
        :title => note.display_name,
        :contents_type => "knowledge-note",
        :publication_symbols => publicities.join(" "),
        :link_url => url_for(:controller => "notes", :action => "show", :id => note),
        :icon_url => icon_url("note.gif")
      }
    end
  end
end
