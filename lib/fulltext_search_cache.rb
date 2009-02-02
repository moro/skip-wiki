class FulltextSearchCache
  attr_accessor :cache_dir
  def initialize(cache_dir, options = {})
    @cache_dir = cache_dir
  end

  def cache_path(builder)
    File.expand_path(builder.filename, cache_dir + "/app_cache/")
  end

  def meta_path(builder)
    File.expand_path(builder.filename, cache_dir + "/app_cache_meta/")
  end
end
