require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/label_indices/index.html.erb" do
  include LabelIndicesHelper
  
  before(:each) do
    assigns[:label_indices] = [
      stub_model(LabelIndex),
      stub_model(LabelIndex)
    ]
  end

  it "should render list of label_indices" do
    render "/label_indices/index.html.erb"
  end
end

