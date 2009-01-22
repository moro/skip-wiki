require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::HistoriesController do
  describe "route generation" do
    it "should map #new" do
      route_for(:controller=>"admin/histories", :action=>"new", :note_id=>"our_note", :page_id=>"our_note_page_1").should == "/admin/notes/our_note/pages/our_note_page_1/histories/new"
    end
  end
  describe "route recognization" do
    it "should generate params for #new" do
      params_from(:get, '/admin/notes/our_note/pages/our_note_page_1/histories/new').should == {:controller=>"admin/histories", :action=>"new", :note_id=>"our_note", :page_id=>"our_note_page_1"}
    end
  end
end
