gem 'skip_collabo'
require "skip_collabo/fulltext_search_cache"

module SkipNoteFulltextSearch
  def self.run(options = {})
    SkipCollabo::FulltextSearchCache.build([
      [Note, NoteCacheBuilder],
      [Page.scoped(:include => [:note, :histories]), PageCacheBuilder],
      [Attachment, AttachmentCacheBuilder],
    ], options)
  end
end

