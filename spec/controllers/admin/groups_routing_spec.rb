require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  describe "route generation" do
    it "should map #show" do
      route_for(:controller=>"admin/groups",:action=>"show",:id=>"1").should == '/admin/groups/1'
    end
  end

  describe "route recognaization" do
    it "should genarate params for #show" do
      params_from(:get, '/admin/groups/show/1') == {:controller=>'admin/groups',:action=>'show',:id=>'1'}
    end
  end
end
