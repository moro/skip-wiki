require "config/environment"
require "fileutils"

class FulltextSearchCache
  DEFAULT_OPTIONS = {
    :cache_dir => File.expand_path("fts_cache/app_cache", Rails.root),
    :entity_dirs => %w[note page attachment],
    :logger    => Rails.logger,
    :limit => 1_000,
  }.freeze

  def self.build(options = {})
    u = URI("http://test.openskip.org/skip-knowledge")
    url_opt = { :host => u.host, :protocol => u.scheme }
    url_opt[:port] = u.port unless (u.scheme == "http" && u.port == 80) || (u.scheme == "https" && u.port == 443)

    ActionController::UrlWriter.default_url_options = url_opt

    mediator = new(options)
    mediator.prepare_dir
    [
      [Note, NoteCacheBuilder],
      [Page.scoped(:include => [:note, :histories]), PageCacheBuilder],
      [Attachment, AttachmentCacheBuilder],
    ].each{|m, b| mediator.build(m, b) }
    mediator.finish
  end

  attr_reader :cache_dir, :built
  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @cache_dir = @options[:cache_dir]
    @built = []

    if since = @options[:since]
      @since = Integer(since).minutes.ago
    end
  end

  def finish
    if built.empty?
      @options[:logger].info{ "[FULLTEXT_SEARCH_CACHE] no model to built cache" }
    else
      @options[:logger].info{ "[FULLTEXT_SEARCH_CACHE] built for #{built.join(", ")}" }
    end
  end

  def build(model, builder)
    if @since
      model = model.scoped(:conditions => ["#{model.quoted_table_name}.updated_at > ?", @since])
    end

    loader(model).each do |obj|
      b = builder.new(obj)
      b.write_cache(self)
      b.write_meta(self)
      built << "#{obj.class.name}:#{obj.id}"
    end
  end

  def loader(model)
    PartialLoader.new(model, @options[:limit])
  end

  def cache_path(builder)
    File.expand_path(builder.filename, cache_dir)
  end

  def meta_path(builder)
    File.expand_path(builder.filename, meta_dir)
  end

  def meta_dir
    dir, base = File.split(cache_dir)
    File.expand_path(base + "_meta", dir)
  end

  def prepare_dir
    [cache_dir, meta_dir].each do |dir|
      @options[:entity_dirs].each do |e|
        d = File.expand_path(File.join(dir, e), cache_dir)
        FileUtils.mkdir_p(d) unless File.directory?(d)
      end
    end
  end
end

