require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SkipAccount do
  before(:each) do
    @valid_attributes = {
      :skip_uid => "value for skip_uid",
      :user => mock_model(User)
    }
  end

  it "should create a new instance given valid attributes" do
    SkipAccount.create!(@valid_attributes)
  end
end
