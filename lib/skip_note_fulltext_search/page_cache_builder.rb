require 'erb'

module SkipNoteFulltextSearch
  class PageCacheBuilder < SkipCollabo::FulltextSearchCache::BuilderBase
    self.entity_name = "page"

    def title; ERB::Util.h(page.display_name) ; end
    def body; page.content ; end

    def to_meta
      publicities = ["note:#{page.note_id}"]
      publicities << "public" if page.published? && page.note.public_readable?
      {
        :title => page.display_name,
        :contents_type => "knowledge-page",
        :publication_symbols => publicities.join(" "),
        :link_url => url_for(:controller => "pages", :action => "show", :id => page, :note_id => page.note),
        :icon_url => icon_url("page.gif"),
      }
    end
  end
end
