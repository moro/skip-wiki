require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Accessibility do
  before(:each) do
    @valid_attributes = {
      :note_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Accessibility.create!(@valid_attributes)
  end
end
