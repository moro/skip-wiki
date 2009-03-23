require 'skip_embedded/fulltext_search_cache/builder_base'

module SkipNoteFulltextSearch
  class AttachmentCacheBuilder < SkipEmbedded::FulltextSearchCache::BuilderBase
    self.entity_name = "attachment"

    def filename
      "attachment/#{attachment.filename}"
    end

    def write_cache(mediator)
      FileUtils.ln_s(attachment.full_filename, mediator.cache_path(self), :force => true)
    end

    def to_meta
      publicities = ["note:#{attachment.attachable_id}"]
      attachable = attachment.attachable
      attachable = attachable.is_a?(Page) ? attachable.note : attachable

      publicities << "public" if attachable.public_readable?
      {
        :title => attachment.display_name,
        :contents_type => "knowledge-attachment",
        :publication_symbols => publicities.join(","),
        :link_url => url_for(:controller => "attachments", :action => "show", :id => attachment, :note_id => attachable),
        :icon_url => icon_url("attachment.gif"),
      }
    end
  end
end

