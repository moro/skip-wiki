require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/notes/show.html.haml" do
  include NotesHelper
  
  before(:each) do
    assigns[:note] = @note = stub_model(Note,
      :name => "value for name",
      :display_name => "value for display_name",
      :publicity => 0
    )
  end

  it "should render attributes in <p>" do
    render "/notes/show.html.haml"
    response.should have_text(/value\ for\ display_name/)
  end
end

