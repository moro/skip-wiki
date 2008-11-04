require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :lang => "value for lang"
    }
  end

  it "should create a new instance given valid attributes" do
    Category.create!(@valid_attributes)
  end
end
