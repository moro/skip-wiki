require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do
  fixtures :notes
  before(:each) do
    @uploaded_data = StringIO.new(File.read("spec/fixtures/data/at_small.png"))
    def @uploaded_data.original_filename; "at_small.png" end
    def @uploaded_data.content_type; "image/png" end

    @valid_attributes = {
      :display_name => "value for display_name",
      :uploaded_data => @uploaded_data,
    }
  end

  it "should create a new instance given valid attributes" do
    notes(:our_note).attachments.create!(@valid_attributes)
  end
end

