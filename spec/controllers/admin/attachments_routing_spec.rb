require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AttachmentsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller=>'admin/attachments', :action=>'index', :note_id=>'our_note').should == "/admin/notes/our_note/attachments"
    end

    it "should map #destroy" do
      route_for(:controller=>"admin/attachments", :action=>"destroy", :note_id=>"our_note", :id=>"our_attachment").should == "/admin/notes/our_note/attachments/our_attachment"
    end 
  end

  describe "route recognization" do
    it "generate params for #index" do
      params_from(:get, '/admin/notes/our_note/attachments').should == {:controller=>"admin/attachments", :action=>'index', :note_id=>'our_note'}
    end

    it "generate params for #create" do
      params_from(:post, '/admin/notes/our_note/attachments').should == {:controller=>"admin/attachments", :action=>"create", :note_id=>"our_note"}
    end

    it "generate params for #delete" do
      params_from(:delete, '/admin/notes/our_note/attachments/our_attachment').should == {:controller=>"admin/attachments", :action=>"destroy", :note_id=>"our_note", :id=>"our_attachment"}
    end 
  end
end
