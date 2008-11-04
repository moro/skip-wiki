require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabelIndexing do
  before(:each) do
    @valid_attributes = {
      :label_index => mock_model(LabelIndex),
      :page => mock_model(Page),
    }
  end

  it "should create a new instance given valid attributes" do
    LabelIndexing.create!(@valid_attributes)
  end
end
