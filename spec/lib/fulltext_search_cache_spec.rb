require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FulltextSearchCache, "new('path/to/cache/root', :since => 15.seconds.ago)", :type => :model do
  before do
    @fts_cache = FulltextSearchCache.new(:cache_dir => 'path/to/cache/root', :url_prefix => "http://example.com", :since => 15.seconds.ago)
  end

  it{ @fts_cache.cache_dir.should == 'path/to/cache/root' }

  describe "出力先パスの算出" do
    before do
      @builder = mock("builder")
      @builder.should_receive(:filename).and_return "file.html"
    end

    it do
      @fts_cache.cache_path(@builder).should == "#{Dir.pwd}/path/to/cache/root/app_cache/file.html"
    end

    it do
      @fts_cache.meta_path(@builder).should == "#{Dir.pwd}/path/to/cache/root/app_cache_meta/file.html"
    end
  end

  describe "#build" do
    fixtures :notes
    before do
      FulltextSearchCache::PartialLoader.should_receive(:new).
        with(Note, anything).and_return(loader = mock("loader"))
      Note.should_receive(:scoped).and_return(Note)
      loader.should_receive(:each).and_yield(notes(:our_note))

      @builder_klass = mock("builder_klass")
      @builder_klass.should_receive(:new).with(notes(:our_note), "http://example.com").and_return(builder = mock("builder"))
      builder.should_receive(:write_cache).with(@fts_cache)
      builder.should_receive(:write_meta).with(@fts_cache)
    end

    it do
      @fts_cache.build(Note, @builder_klass)
    end
  end
end

