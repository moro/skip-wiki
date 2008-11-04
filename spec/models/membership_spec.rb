require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Membership do
  before(:each) do
    @valid_attributes = {
      :user => mock_model(User),
      :group => mock_model(Group),
    }
  end

  it "should create a new instance given valid attributes" do
    Membership.create!(@valid_attributes)
  end
end
