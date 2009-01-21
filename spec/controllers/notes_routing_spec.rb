require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NotesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "notes", :action => "index").should == "/notes"
    end
  
    it "should map #dashboard" do
      route_for(:controller => "notes", :action => "dashboard").should == "/"
    end

    it "should map #new" do
      route_for(:controller => "notes", :action => "new").should == "/notes/new"
    end
  
    it "should map #show" do
      route_for(:controller => "notes", :action => "show", :id => 1).should == "/notes/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "notes", :action => "edit", :id => 1).should == "/notes/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "notes", :action => "update", :id => 1).should == "/notes/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "notes", :action => "destroy", :id => 1).should == "/notes/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/notes").should == {:controller => "notes", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/notes/new").should == {:controller => "notes", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/notes").should == {:controller => "notes", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/notes/1").should == {:controller => "notes", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/notes/1/edit").should == {:controller => "notes", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/notes/1").should == {:controller => "notes", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/notes/1").should == {:controller => "notes", :action => "destroy", :id => "1"}
    end
  end
end
