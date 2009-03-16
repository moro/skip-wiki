gem 'skip_embedded'
require "skip_embedded/fulltext_search_cache"

module SkipNoteFulltextSearch
  def self.run(options = {})
    SkipEmbedded::FulltextSearchCache.build([
      [Note, NoteCacheBuilder],
      [Page.scoped(:include => [:note, :histories]), PageCacheBuilder],
      [Attachment, AttachmentCacheBuilder],
    ], options)
  end
end

