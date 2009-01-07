require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AccountsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => 'admin/accounts', :action => 'index').should == "/admin/accounts"
    end

    it "should map #new" do
      route_for(:controller => 'admin/accounts', :action => 'new').should == "/admin/accounts/new"
    end

    it "should map #show" do
      route_for(:controller => 'admin/accounts', :action => 'show', :id => '1').should == "/admin/accounts/1"
    end

    it "should map #edit" do
      route_for(:controller => 'admin/accounts', :action => 'edit', :id => '1').should == "/admin/accounts/1/edit"
    end
    it "should map #update" do
      route_for(:controller => 'admin/accounts', :action => 'update', :id => '1').should == "/admin/accounts/1"
    end

    it "should map #destroy" do
      route_for(:controller => 'admin/accounts', :action => 'destroy', :id => '1').should == "/admin/accounts/1"
    end
  end

  describe "route recognization" do
    it "should generate params for #index" do
      params_from(:get, '/admin/accounts').should == {:controller => 'admin/accounts', :action => 'index'}
    end
    
    it "should generate params for #new" do
      params_from(:get, '/admin/accounts/new').should == {:controller => 'admin/accounts', :action => 'new'}
    end

    it "should generate params for #create" do
      params_from(:post, '/admin/accounts').should == {:controller => 'admin/accounts', :action => 'create'}
    end

    it "should generate params for #show" do
      params_from(:get, '/admin/accounts/1').should == {:controller => 'admin/accounts', :action => 'show', :id => '1'}
    end

    it "should generate params for #edit" do
      params_from(:get, '/admin/accounts/1/edit').should == {:controller => 'admin/accounts', :action => 'edit', :id => '1'}
    end

    it "should generate params for #update" do
      params_from(:put, '/admin/accounts/1').should == {:controller => 'admin/accounts', :action => 'update', :id => '1'}
    end

    it "should generate params for #delete" do
      params_from(:delete, '/admin/accounts/1').should == {:controller => 'admin/accounts', :action => 'destroy', :id => '1'}
    end
  end
end
