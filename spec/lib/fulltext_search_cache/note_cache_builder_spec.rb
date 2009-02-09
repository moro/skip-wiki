require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'nokogiri'

describe FulltextSearchCache::NoteCacheBuilder, :type => :model do
  fixtures :notes
  before do
    @note = notes(:our_note)
    @builder = FulltextSearchCache::NoteCacheBuilder.new(@note, "http://example.com/skip-knowledge/")
  end

  it { @builder.filename.should == "note/#{@note.id}.html" }

  it "#to_cacheで作られるHTMLのBody部分は@note.descriptionを含むこと" do
    Nokogiri.HTML(@builder.to_cache).search("body").text.should =~ /#{@note.description}/m
  end

  it "#to_cacheで作られるHTMLのtitleは@note.display_nameを含むこと" do
    Nokogiri.HTML(@builder.to_cache).search("title").text.should == @note.display_name
  end

  it "#to_metaのpublication_symbolsは'note:{@note.id} public'であること" do
    @builder.to_meta[:publication_symbols].should == "note:#{@note.id} public"
  end

  it "#to_metaのlink_urlは'http://example.com/skip-knowledge/notes/\#{@note.name}'であること" do
    @builder.to_meta[:link_url].should == "http://example.com/skip-knowledge/notes/#{@note.name}"
  end
end
