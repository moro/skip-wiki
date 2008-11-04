require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabelIndicesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "label_indices", :action => "index", :note_id => "a_note").should == "/notes/a_note/label_indices"
    end

    it "should map #new" do
      route_for(:controller => "label_indices", :action => "new", :note_id => "a_note").should == "/notes/a_note/label_indices/new"
    end

    it "should map #show" do
      route_for(:controller => "label_indices", :action => "show", :id => 1, :note_id => "a_note").should == "/notes/a_note/label_indices/1"
    end

    it "should map #edit" do
      route_for(:controller => "label_indices", :action => "edit", :id => 1, :note_id => "a_note").should == "/notes/a_note/label_indices/1/edit"
    end

    it "should map #update" do
      route_for(:controller => "label_indices", :action => "update", :id => 1, :note_id => "a_note").should == "/notes/a_note/label_indices/1"
    end

    it "should map #destroy" do
      route_for(:controller => "label_indices", :action => "destroy", :id => 1, :note_id => "a_note").should == "/notes/a_note/label_indices/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/notes/a_note/label_indices").should == {:controller => "label_indices", :action => "index", :note_id=>"a_note"}
    end

    it "should generate params for #new" do
      params_from(:get, "/notes/a_note/label_indices/new").should == {:controller => "label_indices", :action => "new", :note_id=>"a_note"}
    end

    it "should generate params for #create" do
      params_from(:post, "/notes/a_note/label_indices").should == {:controller => "label_indices", :action => "create", :note_id=>"a_note"}
    end

    it "should generate params for #show" do
      params_from(:get, "/notes/a_note/label_indices/1").should == {:controller => "label_indices", :action => "show", :id => "1", :note_id=>"a_note"}
    end

    it "should generate params for #edit" do
      params_from(:get, "/notes/a_note/label_indices/1/edit").should == {:controller => "label_indices", :action => "edit", :id => "1", :note_id=>"a_note"}
    end

    it "should generate params for #update" do
      params_from(:put, "/notes/a_note/label_indices/1").should == {:controller => "label_indices", :action => "update", :id => "1", :note_id=>"a_note"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/notes/a_note/label_indices/1").should == {:controller => "label_indices", :action => "destroy", :id => "1", :note_id=>"a_note"}
    end
  end
end
