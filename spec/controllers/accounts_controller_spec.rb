#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 filetype=ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "post :create" do
    before do
      params = {"account"=>{"email"=>"email@example.com"}, "user"=>{"name"=>"ascii", "display_name"=>"Human Name"} }
      session[:identity_url] = "http://openid.example.com/ascii"

      post :create, params
    end

    it{ response.should be_redirect }

    it{ assigns(:account).should_not be_new_record }
    it{ assigns(:account).email.should == "email@example.com" }
    it{ assigns(:account).identity_url.should == "http://openid.example.com/ascii" }

    it{ assigns(:account).user.should_not be_new_record }
    it{ assigns(:account).user.name.should == "ascii" }
    it{ assigns(:account).user.display_name.should == "Human Name" }
  end
end
