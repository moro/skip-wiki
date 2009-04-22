require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'nokogiri'

describe SkipNoteFulltextSearch::NoteCacheBuilder, :type => :model do
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

  fixtures :notes
  before do
    @note = notes(:our_note)
    @builder = SkipNoteFulltextSearch::NoteCacheBuilder.new(@note)
  end

  it { @builder.filename.should == "note/#{@note.id}.html" }

  it "#to_cacheで作られるHTMLのBody部分は@note.descriptionを含むこと" do
    Nokogiri.HTML(@builder.to_cache).search("body").text.should =~ /#{@note.description}/m
  end

  it "#to_cacheで作られるHTMLのtitleは@note.display_nameを含むこと" do
    Nokogiri.HTML(@builder.to_cache).search("title").text.should == @note.display_name
  end

  it "#to_metaのpublication_symbolsは'note:{@note.id} public'であること" do
    @builder.to_meta[:publication_symbols].should == "note:#{@note.id},public"
  end

  it "#to_metaのlink_urlは'http://example.com/skip-knowledge/notes/\#{@note.name}'であること" do
    @builder.to_meta[:link_url].should == "http://example.com/skip-knowledge/notes/#{@note.name}"
  end
end
