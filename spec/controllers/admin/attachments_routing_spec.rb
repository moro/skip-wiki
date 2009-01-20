require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AttachmentsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller=>'admin/attachments', :action=>'index', :note_id=>'our_note').should == "/admin/notes/our_note/attachments"
    end
  end

  describe "route recognization" do
    it "generate params for #index" do
      params_from(:get, '/admin/notes/our_note/attachments').should == {:controller=>"admin/attachments", :action=>'index', :note_id=>'our_note'}
    end
  end
end
