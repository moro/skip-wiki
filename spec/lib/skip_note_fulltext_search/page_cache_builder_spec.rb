require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'nokogiri'

describe SkipNoteFulltextSearch::PageCacheBuilder, :type => :model do
  before :all do
    ActionController::UrlWriter.default_url_options = {
      :host => "example.com",
      :protocol => "http"
    }
    @orig = ActionController::AbstractRequest.relative_url_root
    ActionController::AbstractRequest.relative_url_root = "/skip-knowledge"
  end
  after(:all) do
    ActionController::AbstractRequest.relative_url_root = @orig
  end

  fixtures :pages, :notes
  before do
    @page = pages(:our_note_page_1)
    @builder = SkipNoteFulltextSearch::PageCacheBuilder.new(@page)
  end

  it "#to_cacheで作られるHTMLのBody部分は@page.descriptionを含むこと" do
    @page.should_receive(:content).and_return "hogehoge"
    Nokogiri.HTML(@builder.to_cache).search("body").text.should =~ /hogehoge/m
  end

  it "#to_cacheで作られるHTMLのtitleは@page.display_nameを含むこと" do
    @page.should_receive(:content).and_return "hogehoge"
    Nokogiri.HTML(@builder.to_cache).search("title").text.should == @page.display_name
  end

  it "#to_metaのpublication_symbolsは'note:{@page.id} public'であること" do
    @builder.to_meta[:publication_symbols].should == "note:#{@page.id},public"
  end

  it "#to_metaのlink_urlは'http://example.com/skip-knowledge/notes/\#{@page.note.name}/pages/\#{@page.name}'であること" do
    @builder.to_meta[:link_url].should == "http://example.com/skip-knowledge/notes/#{@page.note.name}/pages/#{@page.name}"
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
