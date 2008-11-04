require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/notes/edit.html.haml" do
  include NotesHelper

  before(:each) do
    assigns[:note] = @note = stub_model(Note,
      :name => "value for name",
      :display_name => "value for display_name"
    )
  end

  it "should render edit form" do
    pending
    render "/notes/edit.html.haml"

    response.should have_tag("form[action=#{note_path(@note)}][method=post]") do
      with_tag('input#note_name[name=?]', "note[name]")
      with_tag('input#note_display_name[name=?]', "note[display_name]")
      with_tag('input#note_sand_box[name=?]', "note[sand_box]")
    end
  end
end


