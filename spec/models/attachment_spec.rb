require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do
  fixtures :notes
  before(:each) do
    @uploaded_data = StringIO.new(File.read("spec/fixtures/data/at_small.png"))
    def @uploaded_data.original_filename; "at_small.png" end
    def @uploaded_data.content_type; "image/png" end

    @valid_attributes = {
      :uploaded_data => @uploaded_data,
    }
  end

  it "should create a new instance given valid attributes" do
    notes(:our_note).attachments.create!(@valid_attributes)
  end

  describe "initialize()" do
    before do
      @attachment = notes(:our_note).attachments.build(@valid_attributes)
    end
    it "should assign display name" do
      @attachment.display_name.should == "at_small.png"
    end

    it "should be valid" do
      @attachment.should be_valid
    end
  end
end

