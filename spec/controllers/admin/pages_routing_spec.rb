require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe PagesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/pages", :action => "index", :note_id => "a_note").should == "/admin/notes/a_note/pages"
    end
  end

  describe "route recognization" do
    it "should generate params for #index" do
      params_from(:get, "/admin/notes/a_note/pages").should == {:controller=>'admin/pages', :action=>'index', :note_id=>"a_note"}
    end
  end
end
