require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabelIndex do
  before(:each) do
    @valid_attributes = {
      :name => "Ruby",
      :note => mock_model(Note)
    }
  end

  it "should create a new instance given valid attributes" do
    LabelIndex.create!(@valid_attributes)
  end
end
