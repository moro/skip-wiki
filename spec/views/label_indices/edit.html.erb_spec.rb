require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/label_indices/edit.html.erb" do
  include LabelIndicesHelper
  
  before(:each) do
    assigns[:label_index] = @label_index = stub_model(LabelIndex,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/label_indices/edit.html.erb"
    
    response.should have_tag("form[action=#{label_index_path(@label_index)}][method=post]") do
    end
  end
end


