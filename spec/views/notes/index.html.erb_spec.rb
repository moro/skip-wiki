require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/notes/index.html.erb" do
  include NotesHelper

  before(:each) do
    assigns[:updated_notes] = [
      stub_model(Note,
        :name => "value for name",
        :display_name => "value for display_name",
        :owner_group_backend_type => "BuiltinGroup",
        :updated_at => Time.now,
        :publicity => 0
      ),
      stub_model(Note,
        :name => "value for name",
        :display_name => "value for display_name",
        :owner_group_backend_type => "SkipGroup",
        :updated_at => Time.now,
        :publicity => 1
      )
    ]
  end

  it "should render list of notes" do
    render "/notes/index.html.haml"
    response.should have_tag("div.updated_title>a", "value for display_name", 2)
    response.should have_tag("div.group>a", "BuiltinGroup", 1)
    response.should have_tag("div.group>a", "SkipGroup", 1)
  end
end

