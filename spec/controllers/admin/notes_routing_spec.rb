require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::NotesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => 'admin/notes', :action => 'index').should == "/admin/notes"
    end

    it "should map #new" do
      route_for(:controller => 'admin/notes', :action => 'new').should == "/admin/notes/new"
    end
 
    it "should map #show" do
      route_for(:controller => 'admin/notes',  :action => 'show', :id => '1').should == "/admin/notes/1"
    end

    it "should map #edit" do
      route_for(:controller => 'admin/notes', :action => 'edit', :id => '1').should == "/admin/notes/1/edit"
    end

    it "should map #update" do
      route_for(:controller => 'admin/notes', :action => 'update', :id => '1').should == "/admin/notes/1"
    end
 
    it "should map #destroy" do
      route_for(:controller => 'admin/notes', :action => 'destroy', :id => '1').should == "/admin/notes/1"
    end
  end
 
  describe "route recognization" do
    it "should generate params for #index" do
      params_from(:get, '/admin/notes').should == {:controller => 'admin/notes', :action => 'index'}
    end

    it "should generate params for #new" do
      params_from(:get, '/admin/notes/new').should == {:controller => 'admin/notes', :action => 'new'}
    end

    it "should generate params for #create" do
      params_from(:post, '/admin/notes').should == {:controller => 'admin/notes', :action => 'create'}
    end

    it "should generate params for #show" do
      params_from(:get, '/admin/notes/1').should == {:controller => 'admin/notes', :action => 'show', :id => '1'}
    end
   
    it "should generate params for #edit" do
      params_from(:get, '/admin/notes/1/edit').should == {:controller => 'admin/notes', :action => 'edit', :id => '1'}
    end

    it "should generate params for #update" do
      params_from(:put, '/admin/notes/1').should == {:controller => 'admin/notes', :action => 'update', :id => '1'}
    end

    it "should generate params for #destroy" do
      params_from(:delete, '/admin/notes/1').should == {:controller => 'admin/notes', :action => 'destroy', :id => '1'}
    end
  end

end
