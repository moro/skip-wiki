require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'nokogiri'

describe SkipNoteFulltextSearch::AttachmentCacheBuilder, :type => :model do
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
  before :all do
    Test::Unit::TestCase.fixture_path = "spec/fixtures/"
  end
  after :all do
    FileUtils.rm_rf File.expand_path("assets/uploaded_data/test", Rails.root)
  end
  before do
    params = {
      :display_name => "hogehoge",
      :uploaded_data => fixture_file_upload("data/at_small.png", "image/png", true),
    }
    @attachment = notes(:our_note).attachments.create(params)
    @builder = SkipNoteFulltextSearch::AttachmentCacheBuilder.new(@attachment)
  end

  describe "メタデータ" do
    it "#to_metaのpublication_symbolsは'note:{@attachment.note_id} public'であること" do
      @builder.to_meta[:publication_symbols].should == "note:#{@attachment.attachable_id},public"
    end

    it {
      @builder.to_meta[:link_url].should == "http://example.com/skip-knowledge/notes/our_note/attachments/#{@attachment.id}"
    }
  end

  describe "#write_cache" do
    before do
      @mediator = mock("mediator")
      @mediator.should_receive(:cache_path).with(@builder).and_return("path")

      FileUtils.should_receive(:ln_s).with(@attachment.full_filename, "path", :force=>true)
    end

    it{ @builder.write_cache(@mediator) }
  end
end
