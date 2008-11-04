require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/label_indices/show.html.erb" do
  include LabelIndicesHelper
  
  before(:each) do
    assigns[:label_index] = @label_index = stub_model(LabelIndex)
  end

  it "should render attributes in <p>" do
    render "/label_indices/show.html.erb"
  end
end

