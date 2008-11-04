require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/label_indices/new.html.erb" do
  include LabelIndicesHelper
  
  before(:each) do
    assigns[:label_index] = stub_model(LabelIndex,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/label_indices/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", label_indices_path) do
    end
  end
end


