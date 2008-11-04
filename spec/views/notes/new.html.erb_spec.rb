require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/notes/new.html.haml" do
  include NotesHelper

  before(:each) do
    user = mock_model(User)
    user.should_receive(:memberships).and_return []
    template.should_receive(:current_user).and_return(user)
    assigns[:note] = mock_model(Note,
      :name => "value for name",
      :display_name => "value for display_name",
      :owner_group_backend_type => "BuiltinGroup",
      :owner_group_backend_id =>nil,
      :publicity => 0
    )
    assigns[:note].should_receive(:new_record?).and_return(true)
  end

  it "should render new form" do
    render "/notes/new.html.haml"

    response.should have_tag("form[action=?][method=post]", notes_path) do
      with_tag("input#note_name[name=?]", "note[name]")
      with_tag("input#note_display_name[name=?]", "note[display_name]")
    end
  end
end


