require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'nokogiri'

describe FulltextSearchCache::PageCacheBuilder, :type => :model do
  fixtures :pages, :notes
  before do
    @page = pages(:our_note_page_1)
    @builder = FulltextSearchCache::PageCacheBuilder.new(@page, "http://example.com/skip-knowledge/")
  end

  it "#to_cacheで作られるHTMLのBody部分は@page.descriptionを含むこと" do
    @page.should_receive(:content).and_return "hogehoge"
    Nokogiri.HTML(@builder.to_cache).search("body").text.should =~ /hogehoge/m
  end

  it "#to_cacheで作られるHTMLのtitleは@page.display_nameを含むこと" do
    @page.should_receive(:content).and_return "hogehoge"
    Nokogiri.HTML(@builder.to_cache).search("title").text.should == @page.display_name
  end

  it "#to_metaのpublification_symbolsは'note:{@page.id} public'であること" do
    @builder.to_meta[:publification_symbols].should == "note:#{@page.id} public"
  end

  it "#to_metaのurlは'http://example.com/skip-knowledge/notes/\#{@page.note.name}/pages/\#{@page.name}'であること" do
    @builder.to_meta[:url].should == "http://example.com/skip-knowledge/notes/#{@page.note.name}/pages/#{@page.name}"
  end

  describe "#write_meta" do
    before do
      fp = mock("file")
      fp.should_receive(:write).with(@builder.to_meta.to_yaml)
      File.should_receive(:open).with("path", "wb").and_yield fp

      @mediator = mock("mediator")
      @mediator.should_receive(:meta_path).with(@builder).and_return("path")
    end

    it{ @builder.write_meta(@mediator) }
  end

  describe "#write_cache" do
    before do
      fp = mock("file")
      fp.should_receive(:write).with(@builder.to_cache)
      File.should_receive(:open).with("path", "wb").and_yield fp

      @mediator = mock("mediator")
      @mediator.should_receive(:cache_path).with(@builder).and_return("path")
    end

    it{ @builder.write_cache(@mediator) }
  end
end
